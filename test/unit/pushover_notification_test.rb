require File.expand_path('../../test_helper', __FILE__)

class PushoverNotificationTest < ActiveSupport::TestCase

  setup do
    @fixture_path = File.expand_path '../../../../../test/fixtures/mail_handler', __FILE__
  end

  test 'should get text from plain text mail' do
    m = Mail.new IO.read File.join @fixture_path, 'ticket_with_long_subject.eml'
    assert n = RedminePushover::Notification.new(m)
    assert msg = n.instance_variable_get('@message')
    assert msg.starts_with?('Lorem ipsum')
    assert msg.ends_with?('John Smith')
  end

  test 'should get text from multipart mail' do
    m = Mail.new IO.read File.join @fixture_path, 'ticket_reply.eml'
    assert n = RedminePushover::Notification.new(m)
    assert_equal 'This is reply', n.instance_variable_get('@message')
  end
end

