class FormFinder

  FORMS = {
    coronavirus_find_support: {
      need_help_with_form: CoronavirusFindSupport::NeedHelpWithForm
    }
  }

  def self.call(flow_name, node_name)
    FORMS.dig flow_name, node_name
  end
end
