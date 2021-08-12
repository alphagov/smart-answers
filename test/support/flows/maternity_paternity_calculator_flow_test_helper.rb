module MaternityPaternityCalculatorFlowTestHelper
  def maternity_responses(up_to: nil,
                          due_date: "2021-05-01",
                          pay_frequency: "weekly",
                          pay_per_frequency: 1000,
                          last_normal_payday: nil,
                          payday_eight_weeks: nil)
    due_date = Date.parse(due_date)
    last_normal_payday = last_normal_payday ? Date.parse(last_normal_payday) : due_date - 4.months
    payday_eight_weeks = payday_eight_weeks ? Date.parse(payday_eight_weeks) : due_date - 6.months

    responses = { what_type_of_leave?: "maternity",
                  baby_due_date_maternity?: due_date.to_s,
                  date_leave_starts?: due_date.to_s,
                  did_the_employee_work_for_you_between?: "yes",
                  last_normal_payday?: last_normal_payday.to_s,
                  payday_eight_weeks?: payday_eight_weeks.to_s }

    responses.merge!(pay_frequency_responses(pay_frequency, pay_per_frequency))
    responses[:how_do_you_want_the_smp_calculated?] = "weekly_starting"
    responses_up_to(responses, up_to)
  end

  def paternity_responses(up_to: nil,
                          due_date: "2021-05-01",
                          pay_frequency: "weekly",
                          pay_per_frequency: 1000,
                          last_normal_payday: nil,
                          payday_eight_weeks: nil)
    due_date = Date.parse(due_date)
    last_normal_payday = last_normal_payday ? Date.parse(last_normal_payday) : due_date - 4.months
    payday_eight_weeks = payday_eight_weeks ? Date.parse(payday_eight_weeks) : due_date - 6.months

    responses = { what_type_of_leave?: "paternity",
                  leave_or_pay_for_adoption?: "no",
                  baby_due_date_paternity?: due_date.to_s,
                  baby_birth_date_paternity?: due_date.to_s,
                  employee_responsible_for_upbringing?: "yes",
                  employee_work_before_employment_start?: "yes",
                  employee_has_contract_paternity?: "yes",
                  employee_on_payroll_paternity?: "yes",
                  employee_still_employed_on_birth_date?: "yes",
                  employee_start_paternity?: due_date.to_s,
                  employee_paternity_length?: "one_week",
                  last_normal_payday_paternity?: last_normal_payday.to_s,
                  payday_eight_weeks_paternity?: payday_eight_weeks.to_s }

    responses.merge!(pay_frequency_responses(pay_frequency, pay_per_frequency, suffix: "paternity"))
    responses[:how_do_you_want_the_spp_calculated?] = "weekly_starting"
    responses_up_to(responses, up_to)
  end

  def maternity_adoption_responses(up_to: nil,
                                   overseas: false,
                                   placement_date: "2021-05-01",
                                   match_date: nil,
                                   last_normal_payday: nil,
                                   payday_eight_weeks: nil,
                                   pay_frequency: "weekly",
                                   pay_per_frequency: 1000)
    placement_date = Date.parse(placement_date)
    match_date = match_date ? Date.parse(match_date) : placement_date - 1.month
    last_normal_payday = last_normal_payday ? Date.parse(last_normal_payday) : placement_date - 4.months
    payday_eight_weeks = payday_eight_weeks ? Date.parse(payday_eight_weeks) : placement_date - 6.months

    responses = { what_type_of_leave?: "adoption",
                  taking_paternity_or_maternity_leave_for_adoption?: "maternity",
                  adoption_is_from_overseas?: overseas ? "yes" : "no",
                  date_of_adoption_match?: match_date.to_s,
                  date_of_adoption_placement?: placement_date.to_s }

    if overseas
      responses.merge!(adoption_date_leave_starts?: placement_date.to_s,
                       adoption_employment_contract?: "yes",
                       adoption_did_the_employee_work_for_you?: "yes",
                       adoption_is_the_employee_on_your_payroll?: "yes")
    else
      responses.merge!(adoption_did_the_employee_work_for_you?: "yes",
                       adoption_employment_contract?: "yes",
                       adoption_is_the_employee_on_your_payroll?: "yes",
                       adoption_date_leave_starts?: placement_date.to_s)
    end

    responses.merge!(last_normal_payday_adoption?: last_normal_payday.to_s,
                     payday_eight_weeks_adoption?: payday_eight_weeks.to_s)

    responses.merge!(pay_frequency_responses(pay_frequency, pay_per_frequency, suffix: "adoption"))
    responses[:how_do_you_want_the_sap_calculated?] = "weekly_starting"
    responses_up_to(responses, up_to)
  end

  def paternity_adoption_responses(up_to: nil,
                                   placement_date: "2021-05-01",
                                   match_date: nil,
                                   last_normal_payday: nil,
                                   payday_eight_weeks: nil,
                                   pay_frequency: "weekly",
                                   pay_per_frequency: 1000)
    placement_date = Date.parse(placement_date)
    match_date = match_date ? Date.parse(match_date) : placement_date - 1.month
    last_normal_payday = last_normal_payday ? Date.parse(last_normal_payday) : placement_date - 4.months
    payday_eight_weeks = payday_eight_weeks ? Date.parse(payday_eight_weeks) : placement_date - 6.months

    responses = { what_type_of_leave?: "paternity",
                  leave_or_pay_for_adoption?: "yes",
                  employee_date_matched_paternity_adoption?: match_date.to_s,
                  padoption_date_of_adoption_placement?: placement_date.to_s,
                  padoption_employee_responsible_for_upbringing?: "yes",
                  employee_work_before_employment_start?: "yes",
                  employee_has_contract_paternity?: "yes",
                  employee_on_payroll_paternity?: "yes",
                  employee_still_employed_on_birth_date?: "yes",
                  employee_start_paternity?: placement_date.to_s,
                  employee_paternity_length?: "one_week",
                  last_normal_payday_paternity?: last_normal_payday.to_s,
                  payday_eight_weeks_paternity?: payday_eight_weeks.to_s }

    responses.merge!(pay_frequency_responses(pay_frequency, pay_per_frequency, suffix: "paternity"))
    responses[:how_do_you_want_the_spp_calculated?] = "weekly_starting"
    responses_up_to(responses, up_to)
  end

private

  def pay_frequency_responses(frequency, pay_per_frequency, suffix: nil)
    frequency_key = suffix ? "pay_frequency_#{suffix}?".to_sym : :pay_frequency?
    earnings_key = suffix ? "earnings_for_pay_period_#{suffix}?".to_sym : :earnings_for_pay_period?

    case frequency
    when "weekly"
      { frequency_key => frequency,
        earnings_key => (pay_per_frequency * 8).to_s,
        :how_many_payments_weekly? => "8" }
    when "every_2_weeks"
      { frequency_key => frequency,
        earnings_key => (pay_per_frequency * 4).to_s,
        :how_many_payments_every_2_weeks? => "4" }
    when "every_4_weeks"
      { frequency_key => frequency,
        earnings_key => pay_per_frequency.to_s,
        :how_many_payments_every_4_weeks? => "1" }
    when "monthly"
      { frequency_key => frequency,
        earnings_key => (pay_per_frequency * 2).to_s,
        :how_many_payments_monthly? => "2" }
    else
      raise "Unknown pay frequency #{frequency}"
    end
  end

  def responses_up_to(responses, up_to)
    responses.each_with_object({}) do |(key, value), memo|
      memo[key] = value
      break memo if up_to == key
    end
  end
end
