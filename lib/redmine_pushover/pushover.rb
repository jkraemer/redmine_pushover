module RedminePushover
  class Pushover
    include HTTParty

    base_uri 'https://api.pushover.net/1'

    def self.send_message(message)
      r = post '/messages.json',
            query: message.merge(token: RedminePushover::api_key)
      if r['status'] == 1
        if Rails.logger.debug?
          Rails.logger.debug "pushover message sent:\n#{message}\n\n#{r}"
        end
        true
      else
        Rails.logger.warn "pushover request failed:\n#{message}\n\n#{r}"
        false
      end
    end

  end
end
