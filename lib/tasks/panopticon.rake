require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task register: :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "smartanswers", kind: "smart-answer")

    puts "Looking up flows, with options: #{FLOW_REGISTRY_OPTIONS}"

    unique_registerables.each do |registerable|
      puts "Registering flow: #{registerable.slug} => #{registerable.title}"
      registerer.register(registerable)
    end
  end

  def unique_registerables
    # Picks smartdown of smart_answer for any dupe keys, same as routing behaviour
    smart_answer_registrables.merge(smartdown_registrables).values
  end

  def smart_answer_registrables
    flow_registry = SmartAnswer::FlowRegistry.new(FLOW_REGISTRY_OPTIONS)

    Hash[flow_registry.flows.collect do |flow|
      [flow.name, FlowRegistrationPresenter.new(flow)]
    end]
  end

  def smartdown_registrables
    Hash[SmartdownAdapter::Registry.instance.flows.collect do |flow|
      [flow.name, SmartdownAdapter::FlowRegistrationPresenter.new(flow)]
    end]
  end
end
