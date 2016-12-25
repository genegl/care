Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'hair_care#index'

  get 'haircare' => 'hair_care#index'
  get 'haircare/:id' => 'hair_care#index'
  get 'haircare/:id/:id' => 'hair_care#index'
  get 'haircare/:id/:id/:id' => 'hair_care#index'
  get 'haircare/:id/:id/:id/:id' => 'hair_care#index'

end