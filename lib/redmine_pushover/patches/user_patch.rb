module RedminePushover
  module Patches
    module UserPatch
      extend ActiveSupport::Concern

      def pushover_key
        pref['pushover_user_key']
      end

      def pushover_connected?
        pushover_key.present?
      end

      def wants_pushover?
        pushover_connected?
      end

      def wants_only_pushover?
        pref.pushover_skip_emails
      end
    end
  end
end

