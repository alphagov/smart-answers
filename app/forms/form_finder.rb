class FormFinder
  FORMS = {
    coronavirus_find_support: {
      able_to_go_out: CoronavirusFindSupport::AbleToGoOutForm,
      afford_food: CoronavirusFindSupport::AffordFoodForm,
      afford_rent_mortgage_bills: CoronavirusFindSupport::AffordRentMortgageBillsForm,
      are_you_off_work_ill: CoronavirusFindSupport::AreYouOffWorkIllForm,
      feel_safe: CoronavirusFindSupport::FeelSafeForm,
      get_food: CoronavirusFindSupport::GetFoodForm,
      have_somewhere_to_live: CoronavirusFindSupport::HaveSomewhereToLiveForm,
      have_you_been_evicted: CoronavirusFindSupport::HaveYouBeenEvictedForm,
      have_you_been_made_unemployed: CoronavirusFindSupport::HaveYouBeenMadeUnemployedForm,
      mental_health_worries: CoronavirusFindSupport::MentalHealthWorriesForm,
      nation: CoronavirusFindSupport::NationForm,
      need_help_with: CoronavirusFindSupport::NeedHelpWithForm,
      results: CoronavirusFindSupport::ResultsForm,
      self_employed: CoronavirusFindSupport::SelfEmployedForm,
      worried_about_work: CoronavirusFindSupport::WorriedAboutWorkForm,
    },
  }.freeze

  def self.call(flow_name, node_name, params, session)
    flow_class = FORMS.dig(flow_name.to_sym, node_name.to_sym)
    flow_class.new(params, session)
  end
end
