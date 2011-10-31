class SweetToothAnswer < SmartAnswer::Flow
  def initialize
    super
    display_name "What's your favourite food?"

    multiple_choice :do_you_like_chocolate? do
      option :yes => :you_have_a_sweet_tooth
      option :no => :do_you_like_jam?
    end

    multiple_choice :do_you_like_jam? do
      option :yes => :you_have_a_sweet_tooth
      option :no => :do_you_like_chocolate?
    end

    outcome :you_have_a_savoury_tooth
    outcome :you_have_a_sweet_tooth
  end
end