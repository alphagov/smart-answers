class MaternityPaternityCalculatorFlow < SmartAnswer::Flow
  def define
    content_id "05d5412d-455b-485e-a570-020c9176a46e"
    name "maternity-paternity-calculator"
    status :published

    ## Q1
    radio :what_type_of_leave? do
      option :maternity
      option :paternity
      option :adoption

      on_response do |response|
        self.leave_type = response

        self.leave_spp_claim_link = nil
        self.notice_of_leave_deadline = nil
        self.monthly_pay_method = nil
        self.period_calculation_method = nil
        self.paternity_adoption = nil
        self.has_contract = nil
        self.paternity_employment_start = nil
      end

      next_node do
        case leave_type
        when "maternity"
          question :baby_due_date_maternity?
        when "paternity"
          question :leave_or_pay_for_adoption?
        when "adoption"
          question :taking_paternity_or_maternity_leave_for_adoption?
        end
      end
    end

    append(AdoptionCalculatorFlow.build)
    append(PaternityCalculatorFlow.build)
    append(MaternityCalculatorFlow.build)
    append(SharedAdoptionMaternityPaternityFlow.build)
  end
end
