class PanopticonRegisterer
  attr_reader :unique_registerables

  def initialize(unique_registerables)
    @unique_registerables = unique_registerables
  end

  def register
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "smartanswers", kind: "smart-answer")

    puts "Looking up flows, with options: #{FLOW_REGISTRY_OPTIONS}"

    unique_registerables.each { |registerable|
      puts "Registering flow: #{registerable.slug} => #{registerable.title}"
      registerer.register(registerable)
    }
  end
end
