module CoronavirusFindSupport
  class NeedHelpWithForm < Form
    attr_accessor :need_help_with

    def self.i18n_scope
      [:session_answers, :coronavirus_find_support, :need_help_with]
    end

    def self.t(translation_name)
      I18n.t(translation_name, scope:i18n_scope)
    end

    delegate :my_scope, :t, to: :class

    validates :need_help_with,
              presence: { message: t("errors.blank") },
              valid_options: true

    def options
      [
        :feeling_unsafe,
        :paying_bills,
        :getting_food,
        :being_unemployed,
        :going_to_work,
        :somewhere_to_live,
        :mental_health,
        :not_sure,
      ].each_with_object({}) { |option, hash| hash[option] = t("options.#{option}") }
    end
  end
end
