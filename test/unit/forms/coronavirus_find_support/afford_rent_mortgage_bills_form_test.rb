require "test_helper"

module CoronavirusFindSupport
  class AffordRentMortgageBillsFormTest < ActiveSupport::TestCase
    def session
      @session ||= {}
    end

    def input
      @input ||= "Yes"
    end

    def params
      @params ||= {
        afford_rent_mortgage_bills: input,
        flow_name: :coronavirus_find_support,
        node_name: :afford_rent_mortgage_bills,
      }
    end

    def form
      @form ||= AffordRentMortgageBillsForm.new(ActionController::Parameters.new(params), session)
    end

    context "#save" do
      should "return true if successful" do
        assert form.save
      end

      should "save input to session" do
        form.save
        assert_equal input, session.dig(form.flow_name, form.node_name)
      end
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
          "Select yes if you’re finding it hard to pay your rent, mortgage or bills",
          form.errors[:afford_rent_mortgage_bills].join,
        )
      end
    end
  end
end
