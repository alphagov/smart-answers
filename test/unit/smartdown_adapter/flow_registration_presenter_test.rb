require_relative "../../test_helper"

module SmartdownAdapter
  class FlowRegistrationPresenterTest < ActiveSupport::TestCase
    context "content_id" do
      should "use the flow content_id" do
        SmartdownAdapter::Registry.reset_instance
        flow_registry_options = {
          show_drafts: true,
          preload_flows: true,
          smartdown_load_path: Rails.root.join('test', 'fixtures', 'smartdown_flows')
        }
        flow = SmartdownAdapter::Registry.instance(flow_registry_options).find("animal-example-simple")

        presenter = SmartdownAdapter::FlowRegistrationPresenter.new(flow)

        assert_equal "5bb6964b-3147-4423-aab3-b87e1cb8b838", presenter.content_id

        SmartdownAdapter::Registry.reset_instance
      end
    end
  end
end
