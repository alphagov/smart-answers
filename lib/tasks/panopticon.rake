require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."
    flow_registry = SmartAnswer::FlowRegistry.new
    
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "smart-answers")
    flow_registry.flows.each do |flow|
      presenter = SmartAnswerPresenter.new(OpenStruct.new(params: {}), flow)
      record = OpenStruct.new(slug: flow.name, title: presenter.title, need_id: flow.need_id, section: flow.section)
      registerer.register(record)
    end
    
    record = OpenStruct.new(slug: 'calculate-your-holiday-entitlement', title: "Calculate your holiday entitlement", section: "Work", need_id: "355")
    registerer.register(record)
  end
end