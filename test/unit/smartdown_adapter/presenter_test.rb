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
          assert_empty @presenter.smartdown_state.responses
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
          assert_equal ["lion"], @presenter.smartdown_state.responses
        end
      end
      context "a started flow with responses" do
        setup do
          request = { started: true, responses: 'lion', params: "" } 
          request.stubs(:query_parameters).returns({ 'response_1' => 'yes' })
          @flow = SmartdownAdapter::Registry.instance.find('animal-example-simple')
          @presenter = SmartdownAdapter::Presenter.new(@flow, request)
        end
        should "initialize sets internal state" do
          assert_equal "animal-example-simple", @presenter.name
          assert @presenter.started
          assert_equal Smartdown::Api::Outcome, @presenter.smartdown_state.current_node.class
          assert_equal ["lion", "yes"], @presenter.smartdown_state.responses
        end
      end
    end
  end
end
