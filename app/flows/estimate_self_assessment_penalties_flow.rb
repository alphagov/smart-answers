class EstimateSelfAssessmentPenaltiesFlow < SmartAnswer::Flow
  def define
    content_id "32b54f44-fca1-4480-b13b-ddeb0b0238e1"
    name "estimate-self-assessment-penalties"
    status :published

    radio :which_year? do
      option :"2017-18"
      option :"2018-19"
      option :"2019-20"
      option :"2020-21"
      option :"2021-22"
      option :"2022-23"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::SelfAssessmentPenalties.new
        calculator.tax_year = response
      end

      next_node do
        question :how_submitted?
      end
    end

    radio :how_submitted? do
      option :online
      option :paper

      on_response do |response|
        calculator.submission_method = response
      end

      next_node do
        question :when_submitted?
      end
    end

    date_question :when_submitted? do
      on_response do |response|
        calculator.filing_date = response
      end

      validate { calculator.valid_filing_date? }

      next_node do
        question :when_paid?
      end
    end

    date_question :when_paid? do
      on_response do |response|
        calculator.payment_date = response
      end

      validate { calculator.valid_payment_date? }

      next_node do
        if calculator.paid_on_time?
          outcome :filed_and_paid_on_time
        else
          question :how_much_tax?
        end
      end
    end

    money_question :how_much_tax? do
      on_response do |response|
        calculator.estimated_bill = response
      end

      next_node do
        outcome :late
      end
    end

    outcome :late

    outcome :filed_and_paid_on_time
  end
end
