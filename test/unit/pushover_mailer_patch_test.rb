require File.expand_path('../../test_helper', __FILE__)

class PushoverMailerPatchTest < ActiveSupport::TestCase
  if Redmine::VERSION::MAJOR < 3
    fixtures :projects, :enabled_modules, :issues, :users,
      :members, :member_roles, :roles, :trackers, :projects_trackers,
      :issue_statuses, :enumerations, :journals
  else
    fixtures :projects, :enabled_modules, :issues, :users, :email_addresses,
      :members, :member_roles, :roles, :trackers, :projects_trackers,
      :issue_statuses, :enumerations, :journals
  end

  ::RedminePushover::Pushover.class_eval do
    cattr_accessor :deliveries
    def self.send_message(msg)
      deliveries << msg
    end
  end

  setup do
    Setting.plugin_redmine_pushover['pushover_url'] = 'https://pushover.net/subscribe/Redmine-someT0ken'
    (@emails = ActionMailer::Base.deliveries).clear
    @push_notifs = RedminePushover::Pushover.deliveries = []
    @user = User.find(3)
    @user.pref['pushover_user_key'] = 'secret'
    @user.pref.save
    @journal = Journal.find(3)
    User.find(2).pref.update_attribute :no_self_notified, false
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
    assert msg = @push_notifs.last
    assert_equal @user.pushover_key, msg[:user]
    assert_equal m.subject, msg[:title]
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
    assert msg = @push_notifs.last
    assert_equal @user.pushover_key, msg[:user]
    assert_equal m.subject, msg[:title]
  end

end
