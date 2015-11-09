module SmartAnswer
  class InheritsSomeoneDiesWithoutWillFlow < Flow
    def define
      content_id "1f75de31-1f07-4c68-b1ab-8330b1ee8670"
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

        next_node :partner?
      end

      # Q2
      multiple_choice :partner? do
        option :"yes"
        option :"no"

        save_input_as :partner

        permitted_next_nodes = [
          :children?,
          :estate_over_250000?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case region
          when 'england-and-wales', 'northern-ireland'
            case response
            when 'yes'
              :estate_over_250000?
            when 'no'
              :children?
            end
          when 'scotland'
            :children?
          end
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

        permitted_next_nodes = [
          :outcome_1,
          :outcome_60,
          :children?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case region
          when 'england-and-wales'
            case response
            when 'yes'
              :children?
            when 'no'
              :outcome_1
            end
          when 'northern-ireland'
            case response
            when 'yes'
              :children?
            when 'no'
              :outcome_60
            end
          end
        end
      end

      # Q4
      multiple_choice :children? do
        option :"yes"
        option :"no"

        save_input_as :children

        permitted_next_nodes = [
          :outcome_1,
          :outcome_2,
          :outcome_20,
          :outcome_40,
          :outcome_66,
          :more_than_one_child?,
          :parents?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case region
          when 'england-and-wales'
            case partner
            when 'yes'
              case response
              when 'yes'
                :outcome_20
              when 'no'
                :outcome_1
              end
            when 'no'
              case response
              when 'yes'
                :outcome_2
              when 'no'
                :parents?
              end
            end
          when 'scotland'
            case partner
            when 'yes'
              case response
              when 'yes'
                :outcome_40
              when 'no'
                :parents?
              end
            when 'no'
              case response
              when 'yes'
                :outcome_2
              when 'no'
                :parents?
              end
            end
          when 'northern-ireland'
            case partner
            when 'yes'
              case response
              when 'yes'
                :more_than_one_child?
              when 'no'
                :parents?
              end
            when 'no'
              case response
              when 'yes'
                :outcome_66
              when 'no'
                :parents?
              end
            end
          end
        end
      end

      # Q5
      multiple_choice :parents? do
        option :"yes"
        option :"no"

        save_input_as :parents

        permitted_next_nodes = [
          :outcome_3,
          :outcome_63,
          :siblings?,
          :siblings_including_mixed_parents?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case region
          when 'england-and-wales'
            case response
            when 'yes'
              :outcome_3
            when 'no'
              :siblings?
            end
          when 'scotland'
            :siblings?
          when 'northern-ireland'
            case partner
            when 'yes'
              case response
              when 'yes'
                :outcome_63
              when 'no'
                :siblings_including_mixed_parents?
              end
            when 'no'
              case response
              when 'yes'
                :outcome_3
              when 'no'
                :siblings?
              end
            end
          end
        end
      end

      # Q6
      multiple_choice :siblings? do
        option :"yes"
        option :"no"

        save_input_as :siblings

        permitted_next_nodes = [
          :outcome_1,
          :outcome_3,
          :outcome_4,
          :outcome_41,
          :outcome_42,
          :outcome_43,
          :outcome_44,
          :aunts_or_uncles?,
          :grandparents?,
          :half_siblings?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case region
          when 'england-and-wales'
            case response
            when 'yes'
              :outcome_4
            when 'no'
              :half_siblings?
            end
          when 'scotland'
            case partner
            when 'yes'
              case parents
              when 'yes'
                case response
                when 'yes'
                  :outcome_43
                when 'no'
                  :outcome_42
                end
              when 'no'
                case response
                when 'yes'
                  :outcome_41
                when 'no'
                  :outcome_1
                end
              end
            when 'no'
              case parents
              when 'yes'
                case response
                when 'yes'
                  :outcome_44
                when 'no'
                  :outcome_3
                end
              when 'no'
                case response
                when 'yes'
                  :outcome_4
                when 'no'
                  :aunts_or_uncles?
                end
              end
            end
          when 'northern-ireland'
            case response
            when 'yes'
              :outcome_4
            when 'no'
              :grandparents?
            end
          end
        end
      end

      # Q61
      multiple_choice :siblings_including_mixed_parents? do
        option :"yes"
        option :"no"

        save_input_as :siblings

        permitted_next_nodes = [
          :outcome_64,
          :outcome_65
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :outcome_64
          when 'no'
            :outcome_65
          end
        end
      end

      # Q7
      multiple_choice :grandparents? do
        option :"yes"
        option :"no"

        save_input_as :grandparents

        permitted_next_nodes = [
          :outcome_5,
          :aunts_or_uncles?,
          :great_aunts_or_uncles?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case region
          when 'england-and-wales'
            case response
            when 'yes'
              :outcome_5
            when 'no'
              :aunts_or_uncles?
            end
          when 'scotland'
            case response
            when 'yes'
              :outcome_5
            when 'no'
              :great_aunts_or_uncles?
            end
          when 'northern-ireland'
            case response
            when 'yes'
              :outcome_5
            when 'no'
              :aunts_or_uncles?
            end
          end
        end
      end

      # Q8
      multiple_choice :aunts_or_uncles? do
        option :"yes"
        option :"no"

        save_input_as :aunts_or_uncles

        permitted_next_nodes = [
          :outcome_6,
          :outcome_67,
          :grandparents?,
          :half_aunts_or_uncles?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case region
          when 'england-and-wales'
            case response
            when 'yes'
              :outcome_6
            when 'no'
              :half_aunts_or_uncles?
            end
          when 'scotland'
            case response
            when 'yes'
              :outcome_6
            when 'no'
              :grandparents?
            end
          when 'northern-ireland'
            case response
            when 'yes'
              :outcome_6
            when 'no'
              :outcome_67
            end
          end
        end
      end

      # Q20
      multiple_choice :half_siblings? do
        option :"yes"
        option :"no"

        save_input_as :half_siblings

        permitted_next_nodes = [
          :outcome_23,
          :grandparents?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :outcome_23
          when 'no'
            :grandparents?
          end
        end
      end

      # Q21
      multiple_choice :half_aunts_or_uncles? do
        option :"yes"
        option :"no"

        save_input_as :half_aunts_or_uncles

        permitted_next_nodes = [
          :outcome_24,
          :outcome_25
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :outcome_24
          when 'no'
            :outcome_25
          end
        end
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

      outcome :outcome_1
      outcome :outcome_2
      outcome :outcome_3
      outcome :outcome_4
      outcome :outcome_5
      outcome :outcome_6

      outcome :outcome_20
      outcome :outcome_23
      outcome :outcome_24

      outcome :outcome_25 do
        precalculate :next_steps do
          [:ownerless_link]
        end
      end

      outcome :outcome_40
      outcome :outcome_41
      outcome :outcome_42
      outcome :outcome_43
      outcome :outcome_44
      outcome :outcome_45

      outcome :outcome_46 do
        precalculate :next_steps do
          [:ownerless_link]
        end
      end

      outcome :outcome_60
      outcome :outcome_61
      outcome :outcome_62
      outcome :outcome_63
      outcome :outcome_64
      outcome :outcome_65
      outcome :outcome_66

      outcome :outcome_67 do
        precalculate :next_steps do
          [:ownerless_link]
        end
      end
    end
  end
end
