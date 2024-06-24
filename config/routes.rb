Rails.application.routes.draw do
  resource :webhooks, only: [:create]
end
