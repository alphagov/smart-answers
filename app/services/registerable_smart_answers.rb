class RegisterableSmartAnswers
  def flow_presenters
    flow_registry = SmartAnswer::FlowRegistry.new(FLOW_REGISTRY_OPTIONS)
    flow_registry.flows.map do |flow|
      FlowRegistrationPresenter.new(flow)
    end
  end
end
