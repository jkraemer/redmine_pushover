require File.expand_path('../../test_helper', __FILE__)

class PushoverCallbacksControllerTest < ActionController::TestCase
  fixtures :users

  setup do
  end

  test 'should require user for activate' do
    get :activate
    assert_redirected_to signin_path(back_url: pushover_activation_url)
  end

  test 'should require user for success' do
    get :success
    assert_redirected_to signin_path(back_url: pushover_success_url)
  end

  test 'should require user for failure' do
    get :failure
    assert_redirected_to signin_path(back_url: pushover_failure_url)
  end

  test 'should not store user key with wrong state' do
    session[:user_id] = 3
    @request.session[:pushover_activation_secret] = 'secret'
    get :success, state: 'wrong', pushover_user_key: 'userkey'
    assert_redirected_to my_account_path
    assert_nil User.find(3).pref['pushover_user_key']
  end

  test 'should store user key on success' do
    session[:user_id] = 3
    @request.session[:pushover_activation_secret] = 'secret'
    get :success, state: 'secret', pushover_user_key: 'userkey'
    assert_redirected_to my_account_path
    assert_equal 'userkey', User.find(3).pref['pushover_user_key']
  end

end
