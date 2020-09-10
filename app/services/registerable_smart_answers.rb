class RegisterableSmartAnswers
  def flow_presenters
    SmartAnswer::FlowRegistry.instance.flows.map do |flow|
      FlowPresenter.new({}, flow)
    end
  end
end
