require 'uri'

require_dependency 'redmine_pushover/patches/mailer_patch'
require_dependency 'redmine_pushover/patches/user_patch'
require_dependency 'redmine_pushover/patches/user_preference_patch'

module RedminePushover
  class << self

    def setup
      Patches::MailerPatch.apply
      Patches::UserPatch.apply
      UserPreference.send :prepend, Patches::UserPreferencePatch
    end

    def api_key
      Setting.plugin_redmine_pushover['pushover_token']
    end

    def configured?
      Setting.plugin_redmine_pushover['pushover_url'].present?
    end

    def strip_signature?
      Setting.plugin_redmine_pushover['strip_signature'].to_s == '1'
    end

    def proxy_options
      {}.tap do |opts|
        if addr = Setting.plugin_redmine_pushover['http_proxy_addr'].presence
          opts[:http_proxy_addr] = addr
          opts[:http_proxy_port] =
            Setting.plugin_redmine_pushover['http_proxy_port'].presence
        end
      end
    end

    def subscription_url(success, failure)
      if configured?
        uri = URI(Setting.plugin_redmine_pushover['pushover_url'])
        query = uri.query.to_s.split('&')
        query << "success=#{URI.escape success}"
        query << "failure=#{URI.escape failure}"
        uri.query = query.join('&')
        uri.to_s
      else
        nil
      end
    rescue URI::InvalidURIError, ArgumentError
      nil
    end

  end

end
