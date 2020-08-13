Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "smart_answers#index"

  get "healthcheck", to: proc { [200, {}, [""]] }

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  constraints id: /[a-z0-9-]+/i, started: /y/ do
    get "/:id/y/visualise(.:format)", to: "smart_answers#visualise", as: :visualise

    get "/:id(/:started(/*responses))",
        to: "smart_answers#show",
        as: :smart_answer,
        format: false
  end

  get "/:flow_name/:node_name", to: "session_answers#show", as: :session_flow
  put "/:flow_name/:node_name", to: "session_answers#update"
  get "/:flow_name", to: "session_answers#index"
end
