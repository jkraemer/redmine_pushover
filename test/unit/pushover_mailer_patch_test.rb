require_relative '../test_helper'

class PushoverMailerPatchTest < ActiveSupport::TestCase
  fixtures :projects, :enabled_modules, :issues, :users, :email_addresses,
    :members, :member_roles, :roles, :trackers, :projects_trackers,
           :issue_statuses, :enumerations, :journals

  ::RedminePushover::Notification.class_eval do
    cattr_accessor :deliveries
    def deliver_to(user)
      self.class.deliveries << [self, user]
    end
  end

  setup do
    Setting.plugin_redmine_pushover['pushover_url'] = 'https://pushover.net/subscribe/Redmine-someT0ken'
    (@emails = ActionMailer::Base.deliveries).clear
    @push_notifs = RedminePushover::Notification.deliveries = []
    @user = User.find(3)
    @user.pref['pushover_user_key'] = 'secret'
    @user.pref.save
    @journal = Journal.find(3)
  end

  test 'should send push notif and email' do
    assert !@user.wants_only_pushover?
    assert_difference '@emails.count', 1 do
      assert_difference '@push_notifs.count', 1 do
        assert Mailer.deliver_issue_edit(@journal)
      end
    end
    assert m = @emails.last
    assert_equal 2, m.bcc.size
    assert m.bcc.include? User.find(2).mail
    assert m.bcc.include? @user.mail
    notif, user = @push_notifs.last
    assert_equal @user, user
    assert_equal m.subject, notif.instance_variable_get(:@subject)
  end

  test 'should send push notif and skip email' do
    @user.pref.pushover_skip_emails = true
    @user.pref.save
    @user.reload
    assert @user.wants_only_pushover?
    assert_difference '@emails.count', 1 do
      assert_difference '@push_notifs.count', 1 do
        assert Mailer.deliver_issue_edit(@journal)
      end
    end
    assert m = @emails.last
    assert_equal 1, m.bcc.size
    assert_equal User.find(2).mail, m.bcc.last
    notif, user = @push_notifs.last
    assert_equal @user, user
    assert_equal m.subject, notif.instance_variable_get(:@subject)
  end

end
