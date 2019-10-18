require_relative "../integration_test_helper"

class ErrorHandlingTest < ActionDispatch::IntegrationTest
  class ExampleController < ApplicationController
    class << self
      attr_accessor :exception_to_raise_before_render
      attr_accessor :exception_to_raise_after_render
    end

    def test
      if self.class.exception_to_raise_before_render
        raise self.class.exception_to_raise_before_render
      end

      render plain: "rendered-from-test-action"
      if self.class.exception_to_raise_after_render
        raise self.class.exception_to_raise_after_render
      end
    end
  end

  setup do
    Rails.application.routes.draw do
      get "/test" => "error_handling_test/example#test"
    end
  end

  teardown do
    Rails.application.reload_routes!
    ExampleController.exception_to_raise_before_render = nil
    ExampleController.exception_to_raise_after_render = nil
  end

  context "when GdsApi::TimedOutException raised before render" do
    setup do
      ExampleController.exception_to_raise_before_render = GdsApi::TimedOutException
    end

    should "set response status code to 503" do
      get "/test"
      assert_response 503
    end
  end

  context "when ActionController::UnknownFormat raised before render" do
    setup do
      ExampleController.exception_to_raise_before_render = ActionController::UnknownFormat
    end

    should "set response status code to 404" do
      get "/test"
      assert_response 404
    end
  end

  context "when GdsApi::HTTPForbidden raised before render" do
    setup do
      ExampleController.exception_to_raise_before_render = GdsApi::HTTPForbidden.new(403)
    end

    should "set response status code to 403" do
      get "/test"
      assert_response 403
    end
  end

  context "when GdsApi::TimedOutException raised after render" do
    setup do
      ExampleController.exception_to_raise_after_render = GdsApi::TimedOutException
    end

    should "set response status code to 503" do
      get "/test"
      assert_response 503
    end
  end

  context "when ActionController::UnknownFormat raised after render" do
    setup do
      ExampleController.exception_to_raise_after_render = ActionController::UnknownFormat
    end

    should "set response status code to 404" do
      get "/test"
      assert_response 404
    end
  end
end
