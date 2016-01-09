Rails.application.routes.draw do
  root 'application#show'
  mount Gatherable::Engine => "/gatherable"
end
