Rails.application.routes.draw do

  post 'signup', to: 'auth#signup'
  post 'login',  to: 'auth#login'

  post 'rtc/events', to: 'webhook#rtc_events'
  get 'rtc/events', to: 'webhook#rtc_events'

  root 'welcome#index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
