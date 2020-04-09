require_relative "../../test_helper"

require "smart_answer_flows/coronavirus-business-support.rb"

module SmartAnswer
  class CoronavirusBusinessSupportViewTest < ActiveSupport::TestCase
    setup do
      @flow = CoronavirusBusinessSupportFlow.build
    end

    context "when rendering :business_based? question" do
      setup do
        question = @flow.node(:business_based?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "england" => "England",
                       "scotland" => "Scotland",
                       "wales" => "Wales",
                       "northern_ireland" => "Northern Ireland" },
                     values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering :business_size? question" do
      setup do
        question = @flow.node(:business_size?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "small_medium_enterprise" => "Small or medium enterprise (SME): 0 to 249 employees.",
                       "large_enterprise" => "Large enterprises: over 249 employees." },
                     values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering :self_employed? question" do
      setup do
        question = @flow.node(:self_employed?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "yes" => "Yes", "no" => "No" }, values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering :annual_turnover? question" do
      setup do
        question = @flow.node(:annual_turnover?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "over_45m" => "Over £45m",
                       "over_85k" => "Over £85,000 and under £45m",
                       "under_85k" => "Under £85,000 (ie not VAT registered)" },
                     values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering :business_rates? question" do
      setup do
        question = @flow.node(:business_rates?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "yes" => "Yes", "no" => "No" }, values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering :non_domestic_property? question" do
      setup do
        question = @flow.node(:non_domestic_property?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "over_51k" => "Over £51,000",
                       "over_15k" => "Over £15,000 and under £51,000",
                       "up_to_15k" => "Up to £15,000",
                       "none" => "My business does not have a non-domestic property" },
                     values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering :self_assessment_july_2020? question" do
      setup do
        question = @flow.node(:self_assessment_july_2020?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "yes" => "Yes", "no" => "No" }, values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering :sectors? question" do
      setup do
        question = @flow.node(:sectors?)
        @state = SmartAnswer::State.new(question)
        @presenter = MultipleChoiceQuestionPresenter.new(question, @state)
      end

      should "have options with labels" do
        assert_equal({ "retail" => "Retail",
                       "hospitality" => "Hospitality",
                       "leisure" => "Leisure",
                       "nurseries" => "Nurseries" },
                     values_vs_labels(@presenter.options))
      end

      should "have a default error message" do
        @state.error = "error-message"
        assert_equal "Please answer this question", @presenter.error
      end
    end

    context "when rendering the result outcome" do
      setup do
        @outcome = @flow.node(:results)
        calculator_options = {
          business_based: "england",
          business_size: "small_medium_enterprise",
          self_employed: "no",
          annual_turnover: "over_85k",
          business_rates: "yes",
          non_domestic_property: "over_15k",
          self_assessment_july_2020: "no",
          sectors: %w[retail hospitality leisure],
        }

        @calculator = stub("calculator", calculator_options)
        @calculator.responds_like_instance_of(Calculators::CoronavirusBusinessSupportCalculator)
        @calculator.stubs(:show_job_retention_scheme?).returns(true)
        @calculator.stubs(:show_vat_scheme?).returns(true)
        @calculator.stubs(:show_self_assessment_payments?).returns(true)
        @calculator.stubs(:show_statutory_sick_rebate?).returns(true)
        @calculator.stubs(:show_self_employed_income_scheme?).returns(true)
        @calculator.stubs(:show_business_rates?).returns(true)
        @calculator.stubs(:show_grant_funding?).returns(true)
        @calculator.stubs(:show_nursery_support?).returns(true)
        @calculator.stubs(:show_small_business_grant_funding?).returns(true)
        @calculator.stubs(:show_business_loan_scheme?).returns(true)
        @calculator.stubs(:show_corporate_financing?).returns(true)
        @calculator.stubs(:show_business_tax_support?).returns(true)
        @state = SmartAnswer::State.new(@outcome)
        @state.calculator = @calculator
      end

      context "common output" do
        setup do
          presenter = OutcomePresenter.new(@outcome, @state)
          @body = presenter.body(html: false)
        end

        should "display title" do
          assert_includes @body, "Coronavirus Job retention Scheme"
        end
      end
    end

    # TODO: add tests for various permutations of results outcome

  private

    def values_vs_labels(options)
      options.inject({}) { |h, o| h[o.value] = o.label; h }
    end
  end
end
