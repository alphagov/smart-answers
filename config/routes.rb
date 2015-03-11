SmartAnswers::Application.routes.draw do
  get 'healthcheck', to: proc { [200, {}, ['']] }

  constraints id: /[a-z0-9-]+/i do
    get '/:id/visualise(.:format)', to: 'smart_answers#visualise', as: :visualise

    get '/:id(/:started(/*responses)).:format',
      to: 'smart_answers#show',
      as: :formatted_smart_answer,
      constraints: { format: /[a-zA-Z]+/ }

    get '/:id(/:started(/*responses))', to: 'smart_answers#show', as: :smart_answer
  end
end
