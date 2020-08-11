class FormFinder
  FORMS = {
    coronavirus_find_support: {
      need_help_with: CoronavirusFindSupport::NeedHelpWithForm,
      feel_safe: CoronavirusFindSupport::FeelSafeForm,
    },
  }.freeze

  def self.call(flow_name, node_name, params, session)
    (FORMS.dig flow_name.to_sym, node_name.to_sym).new(params, session)
  end
end
