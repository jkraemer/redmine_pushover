require_dependency 'redmine_pushover'
require_dependency 'redmine_pushover/view_hooks'

Redmine::Plugin.register :redmine_pushover do
  name 'Redmine Pushover Notifications Plugin'
  url  'http://redmine-search.com/pushover'

  description 'Get push notifications from Redmine via Pushover.'

  author     'Jens Krämer'
  author_url 'https://jkraemer.net/'

  version '1.0.0'

  requires_redmine version_or_higher: '3.1.0'

  settings partial: 'settings/pushover', default: { strip_signature: '1' }
end

Rails.configuration.to_prepare do
  RedminePushover.setup
end

