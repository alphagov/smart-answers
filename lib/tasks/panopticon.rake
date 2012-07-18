require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."
    flow_registry = SmartAnswer::FlowRegistry.new(FLOW_REGISTRY_OPTIONS)

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "smart-answers", kind: "smart-answer")
    flow_registry.flows.each do |flow|
      registerable = FlowRegistrationPresenter.new(flow)
      registerer.register(registerable)
    end
  end
end
