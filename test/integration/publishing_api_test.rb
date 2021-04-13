require_relative "../test_helper"

class PublishingApiTest < ActiveSupport::TestCase
  should "make content_id available for every flow" do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    flow_presenters.each do |flow_presenter|
      message = "The '#{flow_presenter.name}' flow has no 'content_id'"
      assert flow_presenter.content_id.present?, message
    end
  end
end
