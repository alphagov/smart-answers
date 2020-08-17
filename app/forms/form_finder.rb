class FormFinder
  FORMS = {
    coronavirus_find_support: {
      need_help_with: CoronavirusFindSupport::NeedHelpWithForm,
      feel_safe: CoronavirusFindSupport::FeelSafeForm,
      afford_rent_mortgage_bills: CoronavirusFindSupport::AffordRentMortgageBillsForm,
      afford_food: CoronavirusFindSupport::AffordFoodForm,
      get_food: CoronavirusFindSupport::GetFoodForm,
      able_to_go_out: CoronavirusFindSupport::AbleToGoOutForm,
    },
  }.freeze

  def self.call(flow_name, node_name, params, session)
    flow_class = FORMS.dig(flow_name.to_sym, node_name.to_sym)
    flow_class.new(params, session)
  end
end
