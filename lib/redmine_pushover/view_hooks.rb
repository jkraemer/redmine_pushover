module RedminePushover
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_my_account_preferences, partial: 'redmine_pushover/hooks/preferences'
  end
end
