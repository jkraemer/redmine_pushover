module RedminePushover
  module Patches
    module UserPreferencePatch

      def self.apply
        unless UserPreference < self
          UserPreference.prepend self
          UserPreference.class_eval do
            safe_attributes 'pushover_skip_emails'
          end
        end
      end

      def pushover_skip_emails
        self[:pushover_skip_emails] == true || self[:pushover_skip_emails] == '1'
      end

      def pushover_skip_emails=(value)
        byebug
        self[:pushover_skip_emails] = value
      end

    end
  end
end

