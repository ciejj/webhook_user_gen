Rails.application.routes.draw do

  namespace :webhooks do
    resource :applicants, only: [:create]
  end

end
