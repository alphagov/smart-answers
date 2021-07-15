class RadioSampleFlow < SmartAnswer::Flow
  def define
    name "radio-sample"
    content_id "f26e566e-2557-4921-b944-9373c32255f1"

    radio :hotter_or_colder? do
      option :hotter
      option :colder

      next_node do |response|
        case response
        when "hotter"
          outcome :hot
        when "colder"
          question :frozen?
        end
      end
    end

    radio :frozen? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          outcome :frozen
        when "no"
          outcome :cold
        end
      end
    end

    outcome :hot
    outcome :cold
    outcome :frozen
  end
end
