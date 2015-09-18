Rails.application.routes.draw do
  resources :people

  root to: redirect("/people")
end
