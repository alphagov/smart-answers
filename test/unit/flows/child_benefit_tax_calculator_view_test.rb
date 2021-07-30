require_relative "../../test_helper"

class ChildBenefitTaxCalculatorViewTest < ActiveSupport::TestCase
  include ERB::Util

  setup do
    @flow = ChildBenefitTaxCalculatorFlow.build
  end

  # Q1
  context "when rendering how_many_children? question" do
    setup do
      question = @flow.node(:how_many_children?)
      @state = SmartAnswer::State.new(question)
      @presenter = ValueQuestionPresenter.new(question, nil, @state)
    end

    should "display a useful error message when the number entered is bigger than 30" do
      @state.error = "valid_number_of_children"
      assert_equal "Please enter number of children you're claiming for", @presenter.error
    end

    should "display hint text" do
      assert_equal "Number of children", @presenter.hint
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end
  end

  # Q2
  context "when rendering which_tax_year? question" do
    setup do
      question = @flow.node(:which_tax_year?)
      @state = SmartAnswer::State.new(question)
      @presenter = RadioQuestionPresenter.new(question, nil, @state)
    end

    should "have options with labels" do
      assert_equal({ "2012" => "2012 to 2013",
                     "2013" => "2013 to 2014",
                     "2014" => "2014 to 2015",
                     "2015" => "2015 to 2016",
                     "2016" => "2016 to 2017",
                     "2017" => "2017 to 2018",
                     "2018" => "2018 to 2019",
                     "2019" => "2019 to 2020",
                     "2020" => "2020 to 2021",
                     "2021" => "2021 to 2022" }, values_vs_labels(@presenter.options))
    end

    should "display hint text" do
      assert_equal "Tax years run from 6 April to 5 April the following year.", @presenter.hint
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Select a tax year", @presenter.error
    end
  end

  # Q3
  context "when rendering is_part_year_claim? question" do
    setup do
      question = @flow.node(:is_part_year_claim?)
      @state = SmartAnswer::State.new(question)
      @presenter = RadioQuestionPresenter.new(question, nil, @state)
    end

    should "have options with labels" do
      assert_equal({ "yes" => "Yes", "no" => "No" }, values_vs_labels(@presenter.options))
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end
  end

  # Q3a
  context "when rendering how_many_children_part_year? question" do
    setup do
      @question = @flow.node(:how_many_children_part_year?)
      @state = SmartAnswer::State.new(@question)
      @presenter = ValueQuestionPresenter.new(@question, nil, @state)
    end

    should "display hint text" do
      assert_equal "Number of children", @presenter.hint
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please enter a number", @presenter.error
    end

    should "display a useful error message when the number entered is negative, or bigger than the total number of children entered" do
      @state.error = "valid_number_of_part_year_children"
      assert_equal "Please enter a valid number. The number of children you're claiming a part year for can't be more than the total number of children you're claiming for", @presenter.error
    end
  end

  # Q3b
  context "when rendering child_benefit_x_start? questions" do
    setup do
      question = @flow.node(:child_benefit_1_start?)
      calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
      @state = SmartAnswer::State.new(question)
      @state.calculator = calculator
      @presenter = DateQuestionPresenter.new(question, nil, @state)
    end

    should "render the child number" do
      assert_match "Child 1", @presenter.body
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end

    should "display a useful error message when the date entered is not within the tax year selected" do
      @state.error = "valid_within_tax_year"
      assert_equal "Child Benefit start date must be within the tax year selected", @presenter.error
    end

    context "when this question is presented for a later child" do
      should "render the appropriate child number" do
        question = @flow.node(:child_benefit_2_start?)
        state = SmartAnswer::State.new(question)
        state.calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
        state.calculator.child_number = 2
        presenter = DateQuestionPresenter.new(question, nil, state)

        assert_match "Child 2", presenter.body
      end
    end
  end

  # Q3c
  context "when rendering add_child_benefit_x_stop? questions" do
    setup do
      question = @flow.node(:add_child_benefit_1_stop?)
      calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
      @state = SmartAnswer::State.new(question)
      @state.calculator = calculator
      @presenter = RadioQuestionPresenter.new(question, nil, @state)
    end

    should "have options with labels" do
      assert_equal({ "yes" => "Yes", "no" => "No" }, values_vs_labels(@presenter.options))
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end
  end

  # Q3d
  context "when rendering child_benefit_x_stop? question" do
    setup do
      question = @flow.node(:child_benefit_1_stop?)
      calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
      @state = SmartAnswer::State.new(question)
      @state.calculator = calculator
      @presenter = DateQuestionPresenter.new(question, nil, @state)
    end

    should "render the child number" do
      assert_match "Child 1", @presenter.body
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end

    should "display a useful error message when the date entered is not within the tax year selected" do
      @state.error = "valid_within_tax_year"
      assert_equal "Child Benefit stop date must be within the tax year selected", @presenter.error
    end

    context "when this question is presented for a later child" do
      should "render the appropriate child number" do
        question = @flow.node(:child_benefit_2_stop?)
        state = SmartAnswer::State.new(question)
        state.calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
        state.calculator.child_number = 2
        presenter = DateQuestionPresenter.new(question, nil, state)

        assert_match "Child 2", presenter.body
      end
    end
  end

  # Q4
  context "when rendering income_details? question" do
    setup do
      question = @flow.node(:income_details?)
      @state = SmartAnswer::State.new(question)
      @presenter = MoneyQuestionPresenter.new(question, nil, @state)
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please enter a number", @presenter.error
    end
  end

  # Q5
  context "when rendering add_allowable_deductions? question" do
    setup do
      question = @flow.node(:add_allowable_deductions?)
      @state = SmartAnswer::State.new(question)
      @presenter = RadioQuestionPresenter.new(question, nil, @state)
    end

    should "have options with labels" do
      assert_equal({ "yes" => "Yes", "no" => "No" }, values_vs_labels(@presenter.options))
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end
  end

  # Q5a
  context "when rendering allowable_deductions? question" do
    setup do
      question = @flow.node(:allowable_deductions?)
      @state = SmartAnswer::State.new(question)
      @presenter = MoneyQuestionPresenter.new(question, nil, @state)
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end
  end

  # Q6
  context "when rendering add_other_allowable_deductions? question" do
    setup do
      question = @flow.node(:add_other_allowable_deductions?)
      @state = SmartAnswer::State.new(question)
      @presenter = RadioQuestionPresenter.new(question, nil, @state)
    end

    should "have options with labels" do
      assert_equal({ "yes" => "Yes", "no" => "No" }, values_vs_labels(@presenter.options))
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end
  end

  # Q6a
  context "when rendering other_allowable_deductions? question" do
    setup do
      question = @flow.node(:other_allowable_deductions?)
      @state = SmartAnswer::State.new(question)
      @presenter = MoneyQuestionPresenter.new(question, nil, @state)
    end

    should "have a default error message" do
      @state.error = "error-message"
      assert_equal "Please answer this question", @presenter.error
    end
  end

  # outcome
  context "when rendering results page" do
    setup do
      @outcome = @flow.node(:results)
      @calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new(
        tax_year: "2019",
        children_count: 4,
      )
      @state = SmartAnswer::State.new(@outcome)
      @state.calculator = @calculator
    end

    context "when tax year is incomplete" do
      setup do
        travel_to("2019-07-02")
        @calculator.stubs(calculate_adjusted_net_income: SmartAnswer::Money.new(60_000))
        @presenter = OutcomePresenter.new(@outcome, nil, @state)
        @body = @presenter.body
      end

      should "say that it is an estimate" do
        assert_match "This is an estimate based on your adjusted net income of £60,000", @body
      end
    end

    context "when income is below £50,099" do
      setup do
        @calculator.stubs(calculate_adjusted_net_income: SmartAnswer::Money.new(50_098))
        @presenter = OutcomePresenter.new(@outcome, nil, @state)
        @body = @presenter.body
      end

      should "say no tax is owed" do
        assert_match "There is no tax charge if your income is below £50,099.", @body
      end
    end

    context "when income is above £50,100" do
      setup do
        @calculator.stubs(calculate_adjusted_net_income: SmartAnswer::Money.new(50_101))
        @presenter = OutcomePresenter.new(@outcome, nil, @state)
        @body = @presenter.body
      end

      should "say the amount of tax owed" do
        assert_match "The estimated tax charge to pay is £32.00", @body
      end
    end
  end

  context "when the tax year is 2012" do
    setup do
      @outcome = @flow.node(:results)
      @calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new(
        tax_year: "2012",
        children_count: 4,
      )

      @calculator.stubs(calculate_adjusted_net_income: SmartAnswer::Money.new(60_000))
      @state = SmartAnswer::State.new(@outcome)
      @state.calculator = @calculator
      @presenter = OutcomePresenter.new(@outcome, nil, @state)
      @body = @presenter.body
    end

    should "give the dates the benefit is received for" do
      assert_match "Received between 7 January and 5 April 2013.", @body
    end

    should "give the dates the tax is applied to" do
      assert_match "The tax charge only applies to the Child Benefit received between 7 January and 5 April 2013", @body
    end

    should "state that this is only for part of the tax year" do
      assert_match "Your result for the next tax year may be higher because the tax charge will apply to the whole tax year", @body
    end
  end

private

  def values_vs_labels(options)
    options.each_with_object({}) { |o, h| h[o[:value]] = o[:label]; }
  end
end
