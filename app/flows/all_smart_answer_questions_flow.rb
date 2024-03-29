# not a real smart answer, this is here to make testing and changing all front-end elements easier
class AllSmartAnswerQuestionsFlow < SmartAnswer::Flow
  def define
    content_id "92661afb-63ce-4ded-b06e-cf6288c0d629"
    name "all-smart-answer-questions"
    status :draft

    additional_countries = [OpenStruct.new(slug: "mordor", name: "Mordor")]

    checkbox_question :which_checkboxes? do
      option :radagast
      option :mithrandir
      option :olorin
      option :tharkun
      option :elrohir

      next_node do
        question :which_country?
      end
    end

    country_select(:which_country?, additional_countries:) do
      next_node do
        question :which_year?
      end
    end

    year_question :which_year? do
      next_node do
        question :which_year_in_range?
      end
    end

    year_question :which_year_in_range? do
      from { Time.zone.now.year - 1 }
      to { Time.zone.now.year + 1 }

      next_node do
        question :which_date?
      end
    end

    date_question :which_date? do
      next_node do
        question :which_date_of_birth?
      end
    end

    date_question :which_date_of_birth? do
      date_of_birth_defaults

      next_node do
        question :which_date_within_range?
      end
    end

    date_question :which_date_within_range? do
      from { Time.zone.today }
      to { 4.years.since(Time.zone.today) }

      next_node do
        question :which_date_this_year?
      end
    end

    date_question :which_date_this_year? do
      default_year { 0 }

      next_node do
        question :how_much_money?
      end
    end

    money_question :how_much_money? do
      next_node do
        question :which_choice?
      end
    end

    radio :which_choice? do
      option :one
      option :two
      option :three
      option :four

      next_node do
        question :which_boolean_choice?
      end
    end

    radio :which_boolean_choice? do
      option :yes
      option :no

      next_node do
        question :which_postcode?
      end
    end

    postcode_question :which_postcode? do
      next_node do
        question :how_much_salary?
      end
    end

    salary_question :how_much_salary? do
      next_node do
        question :which_value?
      end
    end

    value_question :which_value? do
      next_node do
        outcome :which_integer?
      end
    end

    value_question :which_integer?, parse: Integer do
      next_node do
        outcome :which_float?
      end
    end

    value_question :which_float?, parse: Float do
      next_node do
        outcome :outcome
      end
    end

    outcome :outcome
  end
end
