module SmartAnswer
  class CustomButtonFlow < Flow
    def define
      name "custom-button"
      status :draft
      button_text "Continue"

      value_question :user_input? do
      end
    end
  end
end
