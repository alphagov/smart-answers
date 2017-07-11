module SmartAnswer
  class EstimateSelfAssessmentPenaltiesFlow < Flow
    def define
      start_page_content_id "32b54f44-fca1-4480-b13b-ddeb0b0238e1"
      flow_content_id "14244ee4-6d7d-4e05-90a7-aaf1a776d312"
      name 'estimate-self-assessment-penalties'
      status :published
      satisfies_need "100615"

      multiple_choice :which_year? do
        option :"2012-13"
        option :"2013-14"
        option :"2014-15"
        option :"2015-16"

        on_response do |response|
          self.calculator = Calculators::SelfAssessmentPenalties.new
          calculator.tax_year = response
        end

        next_node do
          question :how_submitted?
        end
      end

      multiple_choice :how_submitted? do
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
        from { 3.year.ago(Date.today) }
        to { 2.years.since(Date.today) }

        on_response do |response|
          calculator.filing_date = response
        end

        validate { calculator.valid_filing_date? }

        next_node do
          question :when_paid?
        end
      end

      date_question :when_paid? do
        from { 3.year.ago(Date.today) }
        to { 2.years.since(Date.today) }

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
end
