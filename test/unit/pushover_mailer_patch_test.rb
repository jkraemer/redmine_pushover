require File.expand_path('../../test_helper', __FILE__)

class PushoverMailerPatchTest < ActiveSupport::TestCase
  fixtures :projects, :enabled_modules, :issues, :users, :email_addresses,
    :members, :member_roles, :roles, :trackers, :projects_trackers,
    :issue_statuses, :enumerations, :journals

  ::RedminePushover::Pushover.class_eval do
    cattr_accessor :deliveries
    def self.send_message(msg)
      deliveries << msg
    end
  end

  setup do
    Member.update_all mail_notification: false
    User.update_all mail_notification: 'none'
    Setting.plugin_redmine_pushover['pushover_url'] = 'https://pushover.net/subscribe/Redmine-someT0ken'
    (@emails = ActionMailer::Base.deliveries).clear
    @push_notifs = RedminePushover::Pushover.deliveries = []
    @user = User.find(3)
    @user.pref['pushover_user_key'] = 'secret'
    @user.pref.save
    @journal = Journal.find(3)
    @user.update_attribute :mail_notification, 'all'
  end

  test 'should send push notif and email' do
    refute @user.wants_only_pushover?

    assert_difference '@emails.count' do
      assert_difference '@push_notifs.count' do
        assert Mailer.deliver_issue_edit(@journal)
      end
    end
    addresses = [:to,:bcc,:cc].map{|k|@emails.map(&k)}.flatten
    assert_equal [@user.mail], addresses
    assert msg = @push_notifs.last
    assert_equal @user.pushover_key, msg[:user]
    assert_equal @emails.last.subject, msg[:title]
  end

  test 'should send push notif and skip email' do
    @user.pref.pushover_skip_emails = true
    @user.pref.save
    @user = User.find @user.id
    assert @user.pref.pushover_skip_emails
    assert @user.wants_only_pushover?
    assert_no_difference '@emails.count' do
      assert_difference '@push_notifs.count' do
        assert Mailer.deliver_issue_edit(@journal)
      end
    end
    assert msg = @push_notifs.last
    assert_equal @user.pushover_key, msg[:user]
  end

end
