SmartAnswers::Application.routes.draw do
  match '/:id(/:started(/*responses)).:format', :to => 'smart_answers#show', :as => :formatted_smart_answer
  match '/:id(/:started(/*responses))', :to => 'smart_answers#show', :as => :smart_answer
end
