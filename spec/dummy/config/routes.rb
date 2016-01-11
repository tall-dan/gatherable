Rails.application.routes.draw do
  root :to => 'application#show'
  mount Gatherable::Engine => "/gatherable"
end
