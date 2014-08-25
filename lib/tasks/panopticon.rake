require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "smartanswers", kind: "smart-answer")
    unique_registerables.each { |registerable|
      registerer.register(registerable)
    }
  end

  def unique_registerables
    # Picks smartdown of smart_answer for any dupe keys, same as routing behaviour
    smart_answer_registrables.merge(smartdown_registrables).values
  end

  def smart_answer_registrables
    flow_registry = SmartAnswer::FlowRegistry.new(FLOW_REGISTRY_OPTIONS)

    Hash[flow_registry.flows.collect { |flow|
      [flow.name, FlowRegistrationPresenter.new(flow)]
    }]
  end

  def smartdown_registrables
    show_drafts = FLOW_REGISTRY_OPTIONS.fetch(:show_drafts, false)
    show_transitions = FLOW_REGISTRY_OPTIONS.fetch(:show_transitions, false)
    Hash[SmartdownAdapter::Registry.flows(FLOW_REGISTRY_OPTIONS).collect { |flow|
      if flow.transition? && show_transitions
        [flow.name, SmartdownAdapter::FlowRegistrationPresenter.new(flow, flow.name + "-transition")]
      elsif flow.draft? && show_drafts
        [flow.name, SmartdownAdapter::FlowRegistrationPresenter.new(flow)]
      end
    }]
  end
end
