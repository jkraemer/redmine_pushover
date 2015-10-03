require_relative '../test_helper'

class RedminePushoverTest < ActiveSupport::TestCase

  setup do
    @base_url = 'https://pushover.net/subscribe/Redmine-someT0ken'
    Setting.plugin_redmine_pushover['pushover_url'] = @base_url
  end

  test 'should compile subscription url' do
    assert url = RedminePushover.subscription_url('success', 'failure')
    assert url.starts_with?(@base_url)
    assert uri = URI.parse(url)
    assert query = uri.query, uri.inspect
    assert fragments = query.split('&').map{|f| f.split('=')}
    assert failure = fragments.detect{|f| f[0] == 'failure'}
    assert_equal 'failure', failure[1]
    assert success = fragments.detect{|f| f[0] == 'success'}
    assert_equal 'success', success[1]
  end
end
