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
    get :success, params: { state: 'wrong', pushover_user_key: 'userkey' }
    assert_redirected_to my_account_path
    assert_nil User.find(3).pref['pushover_user_key']
  end

  test 'should store user key on success' do
    session[:user_id] = 3
    @request.session[:pushover_activation_secret] = 'secret'
    get :success, params: { state: 'secret', pushover_user_key: 'userkey' }
    assert_redirected_to my_account_path
    assert_equal 'userkey', User.find(3).pref['pushover_user_key']
  end

  test 'test action should require login' do
    post :test
    assert_response :redirect
  end

  test 'test action should return 422 when user is not connected' do
    @request.session[:user_id] = 2
    User.find(2).pref['pushover_user_key'] = nil
    User.find(2).pref.save
    post :test
    assert_response :unprocessable_entity
  end

  test 'test action should send notification and return success' do
    @request.session[:user_id] = 2
    User.find(2).pref['pushover_user_key'] = 'testkey123'
    User.find(2).pref.save

    sent = []
    RedminePushover::Pushover.define_method(:send_message) { |msg| sent << msg; true }

    post :test
    assert_response :success
    json = JSON.parse(response.body)
    assert json['success']
    assert_equal 1, sent.size
    assert_equal 'testkey123', sent.first[:user]
  ensure
    RedminePushover::Pushover.singleton_class.remove_method(:send_message) rescue nil
  end

  test 'test action should return success false when pushover fails' do
    @request.session[:user_id] = 2
    User.find(2).pref['pushover_user_key'] = 'testkey123'
    User.find(2).pref.save

    RedminePushover::Pushover.define_method(:send_message) { |msg| false }

    post :test
    assert_response :success
    json = JSON.parse(response.body)
    assert_not json['success']
  ensure
    RedminePushover::Pushover.singleton_class.remove_method(:send_message) rescue nil
  end

end
