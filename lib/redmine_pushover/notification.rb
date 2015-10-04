module RedminePushover
  class Notification

    def initialize(mail)
      @recipients = []
      @title = mail.subject
      @message = mail.text_part.body.to_s
    end

    def add_recipient(user)
      @recipients << user.pushover_user_key
    end

    def deliver!
      message = {
        message: @message,
        title:   @title
      }
      Thread.new do
        @recipients.each do |key|
          message[:user] = key
          Pushover.send_message message
        end
      end
    end
  end
end
