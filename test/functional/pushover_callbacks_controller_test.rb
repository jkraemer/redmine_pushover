require File.expand_path('../../test_helper', __FILE__)

class PushoverCallbacksControllerTest < ActionController::TestCase
  fixtures :users

  setup do
    session[:user_id] = 3
  end

  test 'should require user' do
    session[:user_id] = nil
    get :activate
    assert_redirected_to signin_path(back_url: pushover_activation_url)
    get :success
    assert_redirected_to signin_path(back_url: pushover_success_url)
    get :failure
    assert_redirected_to signin_path(back_url: pushover_failure_url)
  end

  test 'should not store user key with wrong state' do
    @request.session[:pushover_activation_secret] = 'secret'
    get :success, state: 'wrong', pushover_user_key: 'userkey'
    assert_redirected_to my_account_path
    assert_nil User.find(3).pref['pushover_user_key']
  end

  test 'should store user key on success' do
    @request.session[:pushover_activation_secret] = 'secret'
    get :success, state: 'secret', pushover_user_key: 'userkey'
    assert_redirected_to my_account_path
    assert_equal 'userkey', User.find(3).pref['pushover_user_key']
  end

end
