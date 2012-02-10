RequestApp::Application.routes.draw do

  get "request/results"

	root :to => 'request#index'

end
