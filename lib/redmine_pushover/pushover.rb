module RedminePushover
  class Pushover
    include HTTParty

    base_uri 'https://api.pushover.net/1'

    def self.send_message(message = {})
      post '/messages.json',
        query: message.merge(token: RedminePushover::api_key)
    end

  end
end
