class PanopticonRegisterer
  attr_reader :flow_presenters

  def initialize(flow_presenters)
    @flow_presenters = flow_presenters
  end

  def register
    require 'gds_api/panopticon'

    puts "Registering with panopticon..."
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "smartanswers", kind: "smart-answer")

    puts "Looking up flows, with options: #{FLOW_REGISTRY_OPTIONS}"

    flow_presenters.each { |registerable|
      puts "Registering flow: #{registerable.slug} => #{registerable.title}"
      registerer.register(registerable)
    }
  end
end
