
get 'pushover/activate', to: 'pushover_callbacks#activate', as: 'pushover_activation'
get 'pushover/success', to: 'pushover_callbacks#success', as: 'pushover_success'
get 'pushover/failure', to: 'pushover_callbacks#failure', as: 'pushover_failure'
