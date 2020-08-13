require "test_helper"

module CoronavirusFindSupport
  class GetFoodFormTest < ActiveSupport::TestCase
    def session
      @session ||= {}
    end

    def input
      @input ||= "Yes"
    end

    def params
      @params ||= { get_food: input, flow_name: :coronavirus_find_support, node_name: :get_food }
    end

    def form
      @form ||= GetFoodForm.new(ActionController::Parameters.new(params), session)
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
        assert_equal "Select yes if you’re able to get food", form.errors[:get_food].join
      end
    end
  end
end
