class RegisterableSmartAnswers
  def unique_registerables
    # Picks smartdown of smart_answer for any dupe keys, same as routing behaviour
    smart_answer_registrables.merge(smartdown_registrables).values
  end

private

  def smart_answer_registrables
    flow_registry = SmartAnswer::FlowRegistry.new(FLOW_REGISTRY_OPTIONS)

    Hash[flow_registry.flows.collect { |flow|
      [flow.name, FlowRegistrationPresenter.new(flow)]
    }]
  end

  def smartdown_registrables
    Hash[SmartdownAdapter::Registry.instance.flows.collect { |flow|
      [flow.name, SmartdownAdapter::FlowRegistrationPresenter.new(flow)]
    }]
  end
end
