module SmartAnswer
  class InheritsSomeoneDiesWithoutWillFlow < Flow
    def define
      name 'inherits-someone-dies-without-will'
      status :published
      satisfies_need "100988"

      # The case & if blocks in this file are organised to be read in the same order
      # as the flow chart rather than to minimise repetition.

      # Q1
      multiple_choice :region? do
        option :"england-and-wales"
        option :"scotland"
        option :"northern-ireland"

        save_input_as :region

        calculate :next_steps do
          [:wills_link, :inheritance_link]
        end

        calculate :next_step_links do
          PhraseList.new(*next_steps)
        end

        next_node :partner?
      end

      # Q2
      multiple_choice :partner? do
        option :"yes"
        option :"no"

        save_input_as :partner

        on_condition(variable_matches(:region, 'england-and-wales') | variable_matches(:region, 'northern-ireland')) do
          next_node_if(:estate_over_250000?, responded_with('yes'))
          next_node_if(:children?, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'scotland')) do
          next_node(:children?)
        end
      end

      # Q3
      multiple_choice :estate_over_250000? do
        option :"yes"
        option :"no"

        save_input_as :estate_over_250000

        calculate :next_steps do
          if estate_over_250000 == "yes"
            next_steps
          else
            [:wills_link]
          end
        end

        calculate :next_step_links do
          PhraseList.new(*next_steps)
        end

        on_condition(variable_matches(:region, 'england-and-wales')) do
          next_node_if(:children?, responded_with('yes'))
          next_node_if(:outcome_1, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'northern-ireland')) do
          next_node_if(:children?, responded_with('yes'))
          next_node_if(:outcome_60, responded_with('no'))
        end
      end

      # Q4
      multiple_choice :children? do
        option :"yes"
        option :"no"

        save_input_as :children

        on_condition(variable_matches(:region, 'england-and-wales')) do
          on_condition(variable_matches(:partner, 'yes')) do
            next_node_if(:outcome_20, responded_with('yes'))
            next_node_if(:outcome_1, responded_with('no'))
          end
          on_condition(variable_matches(:partner, 'no')) do
            next_node_if(:outcome_2, responded_with('yes'))
            next_node_if(:parents?, responded_with('no'))
          end
        end
        on_condition(variable_matches(:region, 'scotland')) do
          on_condition(variable_matches(:partner, 'yes')) do
            next_node_if(:outcome_40, responded_with('yes'))
            next_node_if(:parents?, responded_with('no'))
          end
          on_condition(variable_matches(:partner, 'no')) do
            next_node_if(:outcome_2, responded_with('yes'))
            next_node_if(:parents?, responded_with('no'))
          end
        end
        on_condition(variable_matches(:region, 'northern-ireland')) do
          on_condition(variable_matches(:partner, 'yes')) do
            next_node_if(:more_than_one_child?, responded_with('yes'))
            next_node_if(:parents?, responded_with('no'))
          end
          on_condition(variable_matches(:partner, 'no')) do
            next_node_if(:outcome_66, responded_with('yes'))
            next_node_if(:parents?, responded_with('no'))
          end
        end
      end

      # Q5
      multiple_choice :parents? do
        option :"yes"
        option :"no"

        save_input_as :parents

        on_condition(variable_matches(:region, 'england-and-wales')) do
          next_node_if(:outcome_3, responded_with('yes'))
          next_node_if(:siblings?, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'scotland')) do
          next_node :siblings?
        end
        on_condition(variable_matches(:region, 'northern-ireland')) do
          on_condition(variable_matches(:partner, 'yes')) do
            next_node_if(:outcome_63, responded_with('yes'))
            next_node_if(:siblings_including_mixed_parents?, responded_with('no'))
          end
          on_condition(variable_matches(:partner, 'no')) do
            next_node_if(:outcome_3, responded_with('yes'))
            next_node_if(:siblings?, responded_with('no'))
          end
        end
      end

      # Q6
      multiple_choice :siblings? do
        option :"yes"
        option :"no"

        save_input_as :siblings

        on_condition(variable_matches(:region, 'england-and-wales')) do
          next_node_if(:outcome_4, responded_with('yes'))
          next_node_if(:half_siblings?, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'scotland')) do
          on_condition(variable_matches(:partner, 'yes')) do
            on_condition(variable_matches(:parents, 'yes')) do
              next_node_if(:outcome_43, responded_with('yes'))
              next_node_if(:outcome_42, responded_with('no'))
            end
            on_condition(variable_matches(:parents, 'no')) do
              next_node_if(:outcome_41, responded_with('yes'))
              next_node_if(:outcome_1, responded_with('no'))
            end
          end
          on_condition(variable_matches(:partner, 'no')) do
            on_condition(variable_matches(:parents, 'yes')) do
              next_node_if(:outcome_44, responded_with('yes'))
              next_node_if(:outcome_3, responded_with('no'))
            end
            on_condition(variable_matches(:parents, 'no')) do
              next_node_if(:outcome_4, responded_with('yes'))
              next_node_if(:aunts_or_uncles?, responded_with('no'))
            end
          end
        end
        on_condition(variable_matches(:region, 'northern-ireland')) do
          next_node_if(:outcome_4, responded_with('yes'))
          next_node_if(:grandparents?, responded_with('no'))
        end
      end

      # Q61
      multiple_choice :siblings_including_mixed_parents? do
        option :"yes"
        option :"no"

        save_input_as :siblings

        next_node_if(:outcome_64, responded_with('yes'))
        next_node_if(:outcome_65, responded_with('no'))
      end

      # Q7
      multiple_choice :grandparents? do
        option :"yes"
        option :"no"

        save_input_as :grandparents

        on_condition(variable_matches(:region, 'england-and-wales')) do
          next_node_if(:outcome_5, responded_with('yes'))
          next_node_if(:aunts_or_uncles?, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'scotland')) do
          next_node_if(:outcome_5, responded_with('yes'))
          next_node_if(:great_aunts_or_uncles?, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'northern-ireland')) do
          next_node_if(:outcome_5, responded_with('yes'))
          next_node_if(:aunts_or_uncles?, responded_with('no'))
        end
      end

      # Q8
      multiple_choice :aunts_or_uncles? do
        option :"yes"
        option :"no"

        save_input_as :aunts_or_uncles

        on_condition(variable_matches(:region, 'england-and-wales')) do
          next_node_if(:outcome_6, responded_with('yes'))
          next_node_if(:half_aunts_or_uncles?, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'scotland')) do
          next_node_if(:outcome_6, responded_with('yes'))
          next_node_if(:grandparents?, responded_with('no'))
        end
        on_condition(variable_matches(:region, 'northern-ireland')) do
          next_node_if(:outcome_6, responded_with('yes'))
          next_node_if(:outcome_67, responded_with('no'))
        end
      end

      # Q20
      multiple_choice :half_siblings? do
        option :"yes"
        option :"no"

        save_input_as :half_siblings

        next_node_if(:outcome_23, responded_with('yes'))
        next_node_if(:grandparents?, responded_with('no'))
      end

      # Q21
      multiple_choice :half_aunts_or_uncles? do
        option :"yes"
        option :"no"

        save_input_as :half_aunts_or_uncles

        next_node_if(:outcome_24, responded_with('yes'))
        next_node_if(:outcome_25, responded_with('no'))
      end

      # Q40
      multiple_choice :great_aunts_or_uncles? do
        option :"yes"
        option :"no"

        save_input_as :great_aunts_or_uncles

        next_node_if(:outcome_45, responded_with('yes'))
        next_node_if(:outcome_46, responded_with('no'))
      end

      # Q60
      multiple_choice :more_than_one_child? do
        option :"yes"
        option :"no"

        save_input_as :more_than_one_child

        next_node_if(:outcome_61, responded_with('yes'))
        next_node_if(:outcome_62, responded_with('no'))
      end

      outcome :outcome_1, use_outcome_templates: true
      outcome :outcome_2, use_outcome_templates: true
      outcome :outcome_3, use_outcome_templates: true
      outcome :outcome_4, use_outcome_templates: true
      outcome :outcome_5, use_outcome_templates: true
      outcome :outcome_6, use_outcome_templates: true

      outcome :outcome_20, use_outcome_templates: true
      outcome :outcome_23, use_outcome_templates: true
      outcome :outcome_24, use_outcome_templates: true

      outcome :outcome_25, use_outcome_templates: true do
        precalculate :next_steps do
          [:ownerless_link]
        end
      end

      outcome :outcome_40, use_outcome_templates: true
      outcome :outcome_41, use_outcome_templates: true
      outcome :outcome_42, use_outcome_templates: true
      outcome :outcome_43, use_outcome_templates: true
      outcome :outcome_44, use_outcome_templates: true
      outcome :outcome_45, use_outcome_templates: true

      outcome :outcome_46, use_outcome_templates: true do
        precalculate :next_steps do
          [:ownerless_link]
        end
      end

      outcome :outcome_60, use_outcome_templates: true
      outcome :outcome_61, use_outcome_templates: true
      outcome :outcome_62, use_outcome_templates: true
      outcome :outcome_63, use_outcome_templates: true
      outcome :outcome_64, use_outcome_templates: true
      outcome :outcome_65, use_outcome_templates: true
      outcome :outcome_66

      outcome :outcome_67 do
        precalculate :next_step_links do
          PhraseList.new(:ownerless_link)
        end
      end
    end
  end
end
