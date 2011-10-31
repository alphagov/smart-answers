SmartAnswers::Application.routes.draw do
  match '/:id(/:started(/*responses))', :to => 'smart_answers#show', :as => :smart_answer
end
