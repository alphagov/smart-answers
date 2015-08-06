# coding:utf-8
require_relative '../../test_helper'

module SmartdownAdapter
  class PresenterTest < ActiveSupport::TestCase
    context "initialize" do
      setup do
        SmartdownAdapter::Registry.reset_instance
        flow_registry_options = {
          show_drafts: true,
          preload_flows: true,
          smartdown_load_path: Rails.root.join('test', 'fixtures', 'smartdown_flows')
        }
        @flow = SmartdownAdapter::Registry.instance(flow_registry_options).find("animal-example-simple")
      end
      teardown do
        SmartdownAdapter::Registry.reset_instance
      end
      context "an unstarted flow" do
        setup do
          request = ActionDispatch::TestRequest.new
          request[:started] = false
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
          request = ActionDispatch::TestRequest.new
          request[:started] = true
          request[:response] = 'lion'
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
          request = ActionDispatch::TestRequest.new
          request[:started] = true
          request[:responses] = 'lion'
          request[:next] = 'y'
          request.stubs(:query_parameters).returns({ 'response_1' => "no" })
          @presenter = SmartdownAdapter::Presenter.new(@flow, request)
        end
        should "initialize sets internal state" do
          assert_equal "animal-example-simple", @presenter.name
          assert @presenter.started
          assert_equal ["lion", "no"], @presenter.current_state.responses
          assert_equal Smartdown::Api::QuestionPage, @presenter.smartdown_state.current_node.class
        end
      end
      context "a flow with an empty response" do
        setup do
          request = ActionDispatch::TestRequest.new
          request[:started] = true
          request[:responses] = 'lion'
          request[:next] = 'y'
          request.stubs(:query_parameters).returns({ "response_1" => "" })
          @presenter = SmartdownAdapter::Presenter.new(@flow, request)
        end
        should "should cast blank responses to nil before giving them to state" do
          assert_equal ["lion"], @presenter.current_state.responses
          assert_equal [""], @presenter.current_state.unaccepted_responses
          assert_equal ["lion", nil], @presenter.instance_variable_get('@responses_url_and_request')
        end
      end
    end
  end
end
