# coding:utf-8
require_relative '../../test_helper'

module SmartdownAdapter
  class PresenterTest < ActiveSupport::TestCase
    context "initialize" do
      setup do
        silence_warnings do
          SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS = {
            show_drafts: true,
            preload_flows: true,
            load_path: Rails.root.join('test', 'fixtures', 'smartdown_flows')
          }
        end
      end
      context "an unstarted flow" do
        setup do
          request = { started: false }
          request.stubs(:query_parameters).returns({})
          @flow = SmartdownAdapter::Registry.instance.find('animal-example-simple')
          @presenter = SmartdownAdapter::Presenter.new(@flow, request)
        end
        should "initialize sets internal state" do
          assert_equal "animal-example-simple", @presenter.name
          refute @presenter.started
          assert_equal Smartdown::Api::Coversheet, @presenter.smartdown_state.current_node.class
          assert_empty @presenter.current_state.responses
        end
      end
      context "a started flow with a response" do
        setup do
          request = { started: true, response: 'lion', params: "" }
          request.stubs(:query_parameters).returns({})
          @flow = SmartdownAdapter::Registry.instance.find('animal-example-simple')
          @presenter = SmartdownAdapter::Presenter.new(@flow, request)
        end
        should "initialize sets internal state" do
          assert_equal "animal-example-simple", @presenter.name
          assert @presenter.started
          assert_equal Smartdown::Api::QuestionPage, @presenter.smartdown_state.current_node.class
          assert_equal ["lion"], @presenter.current_state.responses
        end
      end
      context "a started flow with responses" do
        setup do
          request = { started: true, responses: 'lion', params: "", next: "y" }
          request.stubs(:query_parameters).returns({ 'response_1' => '1999-12-31' })
          @flow = SmartdownAdapter::Registry.instance.find('animal-example-simple')
          @presenter = SmartdownAdapter::Presenter.new(@flow, request)
        end
        should "initialize sets internal state" do
          assert_equal "animal-example-simple", @presenter.name
          assert @presenter.started
          assert_equal ["lion", "1999-12-31"], @presenter.current_state.responses
          assert_equal Smartdown::Api::QuestionPage, @presenter.smartdown_state.current_node.class
        end
      end
      context "a flow with an empty response" do
        setup do
          request = { started: true, responses: "lion", params: "", next: "y" }
          request.stubs(:query_parameters).returns({ "response_1" => "" })
          @flow = SmartdownAdapter::Registry.instance.find("animal-example-simple")
          @presenter = SmartdownAdapter::Presenter.new(@flow, request)
        end
        should "should cast blank responses to nill before giving them to state" do
          assert_equal ["lion"], @presenter.current_state.responses
          assert_equal [""], @presenter.current_state.unaccepted_responses
          assert_equal ["lion", nil], @presenter.instance_variable_get('@responses_url_and_request')
        end
      end
    end
  end
end
