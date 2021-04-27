# ======================================================================
# Allows access to the quesion answers provides custom validations
# and calculations, and other supporting methods.
# ======================================================================

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculator
    RESULT_DATA = YAML.load_file(Rails.root.join("config/smart_answers/next_steps_for_your_business.yml")).freeze

    attr_accessor :annual_turnover_over_85k,
                  :employer,
                  :activities,
                  :needs_financial_support,
                  :business_premises

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
      r1: ->(_) { true },
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
      r13: ->(calculator) { calculator.annual_turnover_over_85k != "no" },
      r14: ->(calculator) { calculator.annual_turnover_over_85k != "no" },
      r15: ->(calculator) { calculator.employer != "no" },
      r16: ->(calculator) { calculator.needs_financial_support == "yes" },
      r17: ->(calculator) { calculator.needs_financial_support == "yes" },
      r18: ->(calculator) { calculator.business_premises.include?("home") },
      r19: ->(calculator) { (calculator.business_premises & %w[rented owned]).empty? },
      r20: ->(calculator) { calculator.employer != "no" },
      r21: ->(calculator) { calculator.business_premises.include?("home") },
      r22: ->(calculator) { calculator.business_premises.exclude?("none") },
      r23: ->(calculator) { calculator.activities.include?("import_goods") },
      r24: ->(calculator) { calculator.activities.include?("export_goods_or_services") },
      r25: ->(calculator) { calculator.activities.include?("sell_online") },
      r26: ->(_) { true },
      r27: ->(calculator) { calculator.annual_turnover_over_85k != "yes" },
    }.with_indifferent_access.freeze
  end
end
