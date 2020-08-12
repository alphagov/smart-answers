require "test_helper"

module CoronavirusFindSupport
  class NeedHelpWithFormTest < ActiveSupport::TestCase
    def session
      @session ||= {}
    end

    def input
      @input ||= %w[feeling_unsafe]
    end

    def params
      @params ||= { need_help_with: input }
    end

    def form
      @form ||= NeedHelpWithForm.new(params, session)
    end

    context "#save" do
      should "return true if successful" do
        assert form.save
      end

      should "save input to session" do
        form.save
        assert_equal input, session.dig(form.flow_name, form.node_name)
      end

      should "not populate errors" do
        form.save
        assert form.errors.empty?
      end
    end

    context "#save with multiple options selected" do
      setup do
        @input = %w[feeling_unsafe paying_bills getting_food]
      end

      should "return true if successful" do
        assert form.save
      end

      should "save input to session" do
        form.save
        assert_equal input, session.dig(form.flow_name, form.node_name)
      end

      should "not populate errors" do
        form.save
        assert form.errors.empty?
      end
    end

    context "#save with incorrect key" do
      setup do
        @params = { unknown: input }
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
        assert_equal "Select what you need to find help with, or ‘Not sure’", form.errors[:need_help_with].join
      end
    end

    context "#save with unknown option" do
      setup do
        @input = %w[unknown]
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
        assert form.errors.present?
      end
    end
  end
end
