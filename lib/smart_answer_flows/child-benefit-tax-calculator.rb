module SmartAnswer
  class ChildBenefitTaxCalculatorFlow < Flow
    def define
      name "child-benefit-tax-calculator"
      start_page_content_id "201fff60-1cad-4d91-a5bf-d7754b866b87"
      flow_content_id "26f5df1d-2d73-4abc-85f7-c09c73332693"
      status :draft

      # Q1
      value_question :how_many_children?, parse: Integer do
        next_node do
          question :which_tax_year?
        end
      end

      # Q2
      radio :which_tax_year? do
        option :"2012"
        option :"2013"
        option :"2014"
        option :"2015"
        option :"2016"
        option :"2017"
        option :"2018"
        option :"2019"
        option :"2020"
        next_node do
          outcome :outcome_1
        end
      end

      outcome :outcome_1
    end
  end
end
