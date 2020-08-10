class FormFinder
  FORMS = {
    coronavirus_find_support: {
      need_help_with: CoronavirusFindSupport::NeedHelpWithForm,
    },
  }.freeze

  def self.call(flow_name, node_name)
    (FORMS.dig flow_name.to_sym, node_name.to_sym).new
  end
end
