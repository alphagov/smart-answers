Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "smart_answers#index"

  get "healthcheck", to: proc { [200, {}, [""]] }

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  constraints id: /[a-z0-9-]+/i, started: /y/ do
    get "/:id/y/visualise(.:format)", to: "smart_answers#visualise", as: :visualise
    get "/:id/outcomes", to: "smart_answers#all_outcomes", as: :all_outcomes
    get "/:id/outcomes/:node_name", to: "smart_answers#outcome", as: :outcome

    get "/:id(/:started(/*responses))",
        to: "smart_answers#show",
        as: :smart_answer,
        format: false
  end

  get "/:id/s/destroy_session", to: "flow#destroy", as: :destroy_flow
  get "/:id/s", to: "flow#start", as: :start_flow
  get "/:id/s/:node_slug", to: "flow#show", as: :flow
  get "/:id/s/:node_slug/next", to: "flow#update", as: :update_flow

  get "/:id/flow/destroy_session", to: "flow#destroy"
  get "/:id/flow", to: "flow#start"
  get "/:id/flow/:node_slug", to: "flow#show"
  get "/:id/flow/:node_slug/next", to: "flow#update"
end
