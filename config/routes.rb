Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "smart_answers#index"

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::EmergencyBannerRedis,
  )

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/:id", to: "flow#landing", as: :flow_landing

  get "/:id/y/visualise(.:format)", to: "smart_answers#visualise", as: :visualise

  # This code has been added to specifically handle the retired register a death abroad URLs, which were a subset of the register a death smart answer
  get "/register-a-death/y/overseas/*other", to: redirect("/register-a-death/y/overseas")

  get "/:id(/y(/*responses))", to: "smart_answers#show", as: :smart_answer, format: false

  get "/:id/start", to: "flow#start", as: :start_flow
  get "/:id/destroy_session", to: "flow#destroy", as: :destroy_flow

  get "/:id/:node_slug", to: "flow#show", as: :flow
  get "/:id/:node_slug/next", to: "flow#update", as: :update_flow
end
