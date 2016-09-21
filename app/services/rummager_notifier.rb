require 'gds_api/rummager'

class RummagerNotifier
  attr_reader :flow_presenters

  def initialize(flow_presenters)
    @flow_presenters = flow_presenters
  end

  def notify
    logger.info "Looking up flows, with options: #{FLOW_REGISTRY_OPTIONS}"

    flow_presenters.each do |flow_presenter|
      logger.info "Indexing '#{flow_presenter.title}' in rummager..."
      SearchIndexer.call(flow_presenter)
    end
  end

private

  def logger
    GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
  end
end
