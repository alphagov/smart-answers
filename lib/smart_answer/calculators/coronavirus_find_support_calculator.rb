module SmartAnswer::Calculators
  class CoronavirusFindSupportCalculator
    attr_accessor :nation,
                  :need_help_with,
                  :feel_safe,
                  :afford_rent_mortgage_bills,
                  :afford_food,
                  :get_food,
                  :self_employed,
                  :worried_about_work,
                  :have_somewhere_to_live,
                  :have_you_been_evicted,
                  :are_you_off_work_ill,
                  :have_you_been_made_unemployed,
                  :mental_health_worries

    def has_results?
      return false if need_help_with.blank?

      need_help_with != "none"
    end

    def needs_help_with?(given_help_item)
      return false unless has_results?

      need_help_with.split(",").include? given_help_item
    end

    def needs_help_in?(given_nation)
      return false if nation.blank?

      nation.split(",").include? given_nation
    end

    def user_feels_unsafe?
      needs_help_with?("feeling_unsafe") && feel_safe != "yes"
    end

    def user_cannot_pay_their_bills?
      needs_help_with?("paying_bills") && afford_rent_mortgage_bills != "no"
    end

    def user_cannot_get_food?
      needs_help_with?("getting_food") && (afford_food != "no" && get_food != "yes")
    end

    def user_is_worried_about_going_to_work?
      needs_help_with?("going_to_work") && worried_about_work != "no"
    end

    def user_is_unemployed?
      needs_help_with?("being_unemployed") && (
        (self_employed != "yes" && have_you_been_made_unemployed != "no") || are_you_off_work_ill == "yes"
      )
    end

    def user_needs_somewhere_to_live?
      needs_help_with?("somewhere_to_live") && (
        have_somewhere_to_live != "yes" || have_you_been_evicted != "no"
      )
    end

    def user_has_mental_health_worries?
      needs_help_with?("mental_health") && mental_health_worries != "no"
    end

    def next_question(current_node)
      nodes = %i[
        need_help_with
        feel_safe
        afford_rent_mortgage_bills
        get_food
        have_you_been_made_unemployed
        are_you_off_work_ill
        have_you_been_evicted
      ]

      if nodes.slice(0..0).include?(current_node) && needs_help_with?("feeling_unsafe")
        :feel_safe
      elsif nodes.slice(0..1).include?(current_node) && needs_help_with?("paying_bills")
        :afford_rent_mortgage_bills
      elsif nodes.slice(0..2).include?(current_node) && needs_help_with?("getting_food")
        :afford_food
      elsif nodes.slice(0..3).include?(current_node) && needs_help_with?("being_unemployed")
        :self_employed
      elsif nodes.slice(0..4).include?(current_node) && needs_help_with?("going_to_work")
        :worried_about_work
      elsif nodes.slice(0..5).include?(current_node) && needs_help_with?("somewhere_to_live")
        :have_somewhere_to_live
      elsif nodes.slice(0..6).include?(current_node) && needs_help_with?("mental_health")
        :mental_health_worries
      else
        :nation
      end
    end
  end
end
