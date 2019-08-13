require 'securerandom'

class PushoverCallbacksController < ApplicationController
  skip_before_action :check_if_login_required
  before_action :require_login

  def activate
    state = session[:pushover_activation_secret] ||= SecureRandom.urlsafe_base64
    success = pushover_success_url state: state
    failure = pushover_failure_url
    redirect_to RedminePushover::subscription_url success, failure
  end

  def success
    key   = params[:pushover_user_key]
    state = params[:state]
    if state.present? && state == session[:pushover_activation_secret]
      if key.blank? && params[:pushover_unsubscribed] == '1'
        User.current.pref['pushover_user_key'] = nil
        User.current.pref.save
        redirect_to my_account_path, notice: l(:flash_pushover_unsubscribed)
      else
        already_subscribed = User.current.pref['pushover_user_key'].present?
        User.current.pref['pushover_user_key'] = key
        User.current.pref.save
        msg = already_subscribed ? l(:flash_pushover_updated) : l(:flash_pushover_success)
        redirect_to my_account_path, notice: msg
      end
    else
      failure
    end
  end

  def failure
    flash[:error] = l(:flash_pushover_failed)
    redirect_to my_account_path
  end
end
