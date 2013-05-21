SmartAnswers::Application.routes.draw do
  constraints :id => /[a-z0-9-]+/i do
    match '/:id(/:started(/*responses)).:format',
      :to => 'smart_answers#show',
      :as => :formatted_smart_answer,
      :constraints => { :format => /[a-zA-Z]+/ }

    match '/:id(/:started(/*responses))', :to => 'smart_answers#show', :as => :smart_answer
  end
end
