require 'uri'

module RedminePushover
  class << self

    def setup
      ::Mailer.prepend Patches::MailerPatch
      ::User.prepend Patches::UserPatch
      ::UserPreference.prepend Patches::UserPreferencePatch
      RedminePushover::ViewHooks # just load it
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
        params = { success: success, failure: failure }
        query = URI.decode_www_form(uri.query || '') + params.to_a
        uri.query = URI.encode_www_form(query)
        uri.to_s
      else
        nil
      end
    rescue URI::InvalidURIError, ArgumentError
      nil
    end

  end
end
