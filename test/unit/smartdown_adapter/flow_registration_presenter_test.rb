require_relative "../../test_helper"

module SmartdownAdapter
  class FlowRegistrationPresenterTest < ActiveSupport::TestCase
    context "content_id" do
      should "use the flow content_id" do
        flow = SmartdownAdapter::Registry.instance.find('pay-leave-for-parents')

        presenter = SmartdownAdapter::FlowRegistrationPresenter.new(flow)

        assert_equal "1f6b4ecc-ce2c-488a-b9c7-b78b3bba5598", presenter.content_id
      end
    end
  end
end
