module RedminePushover
  class Notification

    def initialize(mail)
      @recipients = []
      @title = mail.subject
      @message = get_message(mail)
    end

    def get_message(mail)
      mail.text_part.body.to_s.tap do |text|
        text.sub! /^-- ?\n.*\z/m, '' if RedminePushover::strip_signature?
        text.strip!
      end
    end

    def add_recipient(user)
      @recipients << user.pushover_key
    end

    def deliver!
      message = {
        message: @message,
        title:   @title
      }
      t = Thread.new do
        @recipients.each do |key|
          message[:user] = key
          Pushover.send_message message
        end
      end
      t.join if Rails.env.test?
      @recipients.count
    end
  end
end
