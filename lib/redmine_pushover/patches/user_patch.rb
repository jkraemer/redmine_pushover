module RedminePushover
  module Patches
    module UserPatch

      def self.apply
        User.class_eval do
          prepend InstanceMethods

          # Redmine < 3(.1?)
          unless respond_to?(:having_mail)
            scope :having_mail, lambda {|arg|
              addresses = Array.wrap(arg).map {|a| a.to_s.downcase}
              if addresses.any?
                where("LOWER(#{table_name}.mail) IN (?)", addresses)
              else
                none
              end
            }
          end
        end
      end

      module InstanceMethods

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
end

