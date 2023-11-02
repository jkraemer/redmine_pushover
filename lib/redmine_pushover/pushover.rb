module RedminePushover
  class Pushover
    include HTTParty

    base_uri 'https://api.pushover.net/1'

    def self.send_message(message)
      options = RedminePushover.proxy_options
      options[:query] = message.merge(token: RedminePushover.api_key)

      r = post '/messages.json', options
      if r['status'] == 1
        Rails.logger.debug { "pushover message sent:\n#{message}\n\n#{r}" }
        true
      else
        Rails.logger.warn { "pushover request failed:\n#{message}\n\n#{r}" }
        false
      end
    end

  end
end
