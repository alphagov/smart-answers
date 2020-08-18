require "test_helper"

module CoronavirusFindSupport
  class FeelSafeFormTest < ActiveSupport::TestCase
    def session
      @session ||= {}
    end

    def input
      @input ||= "Yes"
    end

    def params
      @params ||= { feel_safe: input, flow_name: :coronavirus_find_support, node_name: :feel_safe }
    end

    def form
      @form ||= FeelSafeForm.new(ActionController::Parameters.new(params), session)
    end

    context "#save" do
      should "return true if successful" do
        assert form.save
      end

      # Out of date
      # should "save input to session" do
      #   form.save
      #   assert_equal input, session.dig(form.flow_name, form.node_name)
      # end
    end

    context "#save no entry" do
      setup do
        @params = {}
      end

      should "not return true" do
        assert_not form.save
      end

      should "not save input to session" do
        form.save
        assert_nil session.dig(form.flow_name, form.node_name)
      end

      should "populate errors" do
        form.save
        assert_equal(
          "Select if you feel safe where you live or if you’re worried about someone else",
          form.errors[:feel_safe].join,
        )
      end
    end
  end
end
