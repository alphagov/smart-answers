class HelpIfYouAreArrestedAbroadFlow < SmartAnswer::Flow
  def define
    content_id "cb62c931-a0fa-4363-b33d-12ac06d6232a"
    name "help-if-you-are-arrested-abroad"
    status :published

    exclude_countries = %w[holy-see british-antarctic-territory]
    british_overseas_territories = %w[anguilla bermuda british-indian-ocean-territory british-virgin-islands cayman-islands falkland-islands gibraltar montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-the-south-sandwich-islands turks-and-caicos-islands]

    # Q1
    country_select :which_country?, exclude_countries: exclude_countries do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::ArrestedAbroad.new(response)
      end

      next_node do |response|
        if response == "syria"
          outcome :answer_three_syria
        elsif british_overseas_territories.include?(response)
          outcome :answer_three_british_overseas_territories
        else
          outcome :answer_one_generic
        end
      end
    end

    outcome :answer_one_generic

    outcome :answer_three_syria

    outcome :answer_three_british_overseas_territories
  end
end
