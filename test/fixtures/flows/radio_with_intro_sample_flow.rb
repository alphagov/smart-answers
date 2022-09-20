class RadioWithIntroSampleFlow < SmartAnswer::Flow
  def define
    name "radio-with-intro-sample"
    content_id "f26e566e-2557-4921-b944-9373c32255f1"

    radio_with_intro :colour_options? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          outcome :supported_colour
        when "no"
          outcome :no_colour_matches
        end
      end
    end

    outcome :supported_colour
    outcome :no_colour_matches
  end
end
