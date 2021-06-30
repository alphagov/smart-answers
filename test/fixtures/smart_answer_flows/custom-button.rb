module SmartAnswer
  class CustomButtonFlow < Flow
    def define
      name "custom-button"
      status :draft

      start_page

      value_question :user_input? do
      end
    end
  end
end
