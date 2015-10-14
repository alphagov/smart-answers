module SmartAnswer
  class CheckboxSampleFlow < Flow
    def define
      name 'checkbox-sample'
      status :draft

      checkbox_question :what_do_you_want_on_your_pizza? do
        option :ham
        option :peppers
        option :ice_cream
        option :pepperoni

        save_input_as :toppings

        permitted_next_nodes = [
          :margherita,
          :no_way,
          :on_its_way
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'none'
            :margherita
          else
            toppings = response.split(',')
            if toppings.include?('ice_cream')
              :no_way
            else
              :on_its_way
            end
          end
        end
      end

      outcome :margherita
      outcome :on_its_way
      outcome :no_way
    end
  end
end
