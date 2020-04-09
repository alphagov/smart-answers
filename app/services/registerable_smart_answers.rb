class RegisterableSmartAnswers
  def flow_presenters
    SmartAnswer::FlowRegistry.instance.flows.map do |flow|
      FlowRegistrationPresenter.new(flow)
    end
  end
end
