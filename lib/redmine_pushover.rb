require 'uri'

module RedminePushover
  class << self

    def setup
    end

    def api_key
      Setting.plugin_redmine_pushover['pushover_token']
    end

    def configured?
      Setting.plugin_redmine_pushover['pushover_url'].present?
    end

    def connected?
      User.current.pref['pushover_user_key'].present?
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
