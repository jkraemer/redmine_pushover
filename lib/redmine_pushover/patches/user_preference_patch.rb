module RedminePushover
  module Patches
    module UserPreferencePatch

      def pushover_skip_emails; (self[:pushover_skip_emails] == true || self[:pushover_skip_emails] == '1'); end
      def pushover_skip_emails=(value); self[:pushover_skip_emails]=value; end

    end
  end
end

