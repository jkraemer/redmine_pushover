module RedminePushover
  module Patches
    module UserPreferencePatch
      extend ActiveSupport::Concern

      prepended do
        safe_attributes 'pushover_skip_emails'
      end

      def pushover_skip_emails
        self[:pushover_skip_emails] == true || self[:pushover_skip_emails] == '1'
      end

      def pushover_skip_emails=(value)
        self[:pushover_skip_emails] = value
      end
    end
  end
end