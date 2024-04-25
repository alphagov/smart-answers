# ======================================================================
# Allows access to the quesion answers provides custom validations
# and calculations, and other supporting methods.
# ======================================================================

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculator
    RESULT_DATA = YAML.load_file(Rails.root.join("config/smart_answers/next_steps_for_your_business.yml")).freeze

    attr_accessor :annual_turnover_over_90k,
                  :employer,
                  :activities,
                  :needs_financial_support,
                  :business_premises,
                  :registered_for_corp_tax

    def grouped_results
      grouped_results = filtered_results.group_by { |result| result["group"] }

      grouped_results.transform_values do |results|
        results.group_by { |result| result["topic"] }
      end
    end

    def filtered_results
      RESULT_DATA.select do |result|
        RULES[result["id"]].call(self)
      end
    end

    RULES = {
      r1: ->(calculator) { calculator.registered_for_corp_tax != true },
      r2: ->(_) { true },
      r3: ->(_) { true },
      r4: ->(_) { true },
      r5: ->(_) { true },
      r6: ->(_) { true },
      r7: ->(_) { true },
      r8: ->(_) { true },
      r9: ->(_) { true },
      r10: ->(_) { true },
      r11: ->(_) { true },
      r12: ->(_) { true },
      r13: ->(_) { true },
      r14: ->(_) { true },
      r15: ->(_) { true },
      r16: ->(calculator) { calculator.annual_turnover_over_90k == "yes" },
      r17: ->(calculator) { calculator.annual_turnover_over_90k == "not_sure" },
      r18: ->(calculator) { calculator.employer != "no" },
      r19: ->(calculator) { calculator.needs_financial_support == "yes" },
      r20: ->(calculator) { calculator.needs_financial_support == "yes" },
      r21: ->(calculator) { calculator.employer != "no" },
      r22: ->(calculator) { calculator.business_premises.include?("home") },
      r23: ->(calculator) { calculator.business_premises.include?("rented") },
      r24: ->(calculator) { (calculator.business_premises & %w[rented owned none]).present? },
      r25: ->(calculator) { (calculator.business_premises & %w[rented owned none]).present? },
      r26: ->(calculator) { calculator.activities.include?("import_goods") },
      r27: ->(calculator) { calculator.activities.include?("export_goods_or_services") },
      r28: ->(calculator) { calculator.annual_turnover_over_90k == "yes" },
      r29: ->(calculator) { calculator.annual_turnover_over_90k == "no" },
      r30: ->(calculator) { calculator.activities.include?("export_goods_or_services") },
    }.with_indifferent_access.freeze
  end
end
