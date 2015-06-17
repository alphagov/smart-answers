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

        calculate :next_step_links do
          PhraseList.new(:wills_link, :inheritance_link)
        end

        next_node do |response|
          :partner?
        end
      end

      # Q2
      multiple_choice :partner? do
        option :"yes"
        option :"no"

        save_input_as :partner

        next_node do |response|
          if region == 'england-and-wales' || region == 'northern-ireland'
            if response == 'yes'
              :estate_over_250000?
            elsif response == 'no'
              :children?
            end
          elsif region == 'scotland'
            :children?
          end
        end
      end

      # Q3
      multiple_choice :estate_over_250000? do
        option :"yes"
        option :"no"

        save_input_as :estate_over_250000

        calculate :next_step_links do
          if estate_over_250000 == "yes"
            next_step_links
          else
            PhraseList.new(:wills_link)
          end
        end

        next_node do |response|
          if region == 'england-and-wales'
            if response == 'yes'
              :children?
            elsif response == 'no'
              :outcome_1
            end
          elsif region == 'northern-ireland'
            if response == 'yes'
              :children?
            elsif response == 'no'
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

        next_node do |response|
          if region == 'england-and-wales'
            if partner == 'yes'
              if response == 'yes'
                :outcome_20
              elsif response == 'no'
                :outcome_1
              end
            elsif partner == 'no'
              if response == 'yes'
                :outcome_2
              elsif response == 'no'
                :parents?
              end
            end
          elsif region == 'scotland'
            if partner == 'yes'
              if response == 'yes'
                :outcome_40
              elsif response == 'no'
                :parents?
              end
            elsif partner == 'no'
              if response == 'yes'
                :outcome_2
              elsif response == 'no'
                :parents?
              end
            end
          elsif region == 'northern-ireland'
            if partner == 'yes'
              if response == 'yes'
                :more_than_one_child?
              elsif response == 'no'
                :parents?
              end
            elsif partner == 'no'
              if response == 'yes'
                :outcome_66
              elsif response == 'no'
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

        next_node do |response|
          if region == 'england-and-wales'
            if response == 'yes'
              :outcome_3
            elsif response == 'no'
              :siblings?
            end
          elsif region == 'scotland'
            :siblings?
          elsif region == 'northern-ireland'
            if partner == 'yes'
              if response == 'yes'
                :outcome_63
              elsif response == 'no'
                :siblings_including_mixed_parents?
              end
            elsif partner == 'no'
              if response == 'yes'
                :outcome_3
              elsif response == 'no'
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

        next_node do |response|
          if region == 'england-and-wales'
            if response == 'yes'
              :outcome_4
            elsif response == 'no'
              :half_siblings?
            end
          elsif region == 'scotland'
            if partner == 'yes'
              if parents == 'yes'
                if response == 'yes'
                  :outcome_43
                elsif response == 'no'
                  :outcome_42
                end
              elsif parents == 'no'
                if response == 'yes'
                  :outcome_41
                elsif response == 'no'
                  :outcome_1
                end
              end
            elsif partner == 'no'
              if parents == 'yes'
                if response == 'yes'
                  :outcome_44
                elsif response == 'no'
                  :outcome_3
                end
              elsif parents == 'no'
                if response == 'yes'
                  :outcome_4
                elsif response == 'no'
                  :aunts_or_uncles?
                end
              end
            end
          elsif region == 'northern-ireland'
            if response == 'yes'
              :outcome_4
            elsif response == 'no'
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

        next_node do |response|
          if response == 'yes'
            :outcome_64
          elsif response == 'no'
            :outcome_65
          end
        end
      end

      # Q7
      multiple_choice :grandparents? do
        option :"yes"
        option :"no"

        save_input_as :grandparents

        next_node do |response|
          if region == 'england-and-wales'
            if response == 'yes'
              :outcome_5
            elsif response == 'no'
              :aunts_or_uncles?
            end
          elsif region == 'scotland'
            if response == 'yes'
              :outcome_5
            elsif response == 'no'
              :great_aunts_or_uncles?
            end
          elsif region == 'northern-ireland'
            if response == 'yes'
              :outcome_5
            elsif response == 'no'
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

        next_node do |response|
          if region == 'england-and-wales'
            if response == 'yes'
              :outcome_6
            elsif response == 'no'
              :half_aunts_or_uncles?
            end
          elsif region == 'scotland'
            if response == 'yes'
              :outcome_6
            elsif response == 'no'
              :grandparents?
            end
          elsif region == 'northern-ireland'
            if response == 'yes'
              :outcome_6
            elsif response == 'no'
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

        next_node do |response|
          if response == 'yes'
            :outcome_23
          elsif response == 'no'
            :grandparents?
          end
        end
      end

      # Q21
      multiple_choice :half_aunts_or_uncles? do
        option :"yes"
        option :"no"

        save_input_as :half_aunts_or_uncles

        next_node do |response|
          if response == 'yes'
            :outcome_24
          elsif response == 'no'
            :outcome_25
          end
        end
      end

      # Q40
      multiple_choice :great_aunts_or_uncles? do
        option :"yes"
        option :"no"

        save_input_as :great_aunts_or_uncles

        next_node do |response|
          if response == 'yes'
            :outcome_45
          elsif response == 'no'
            :outcome_46
          end
        end
      end

      # Q60
      multiple_choice :more_than_one_child? do
        option :"yes"
        option :"no"

        save_input_as :more_than_one_child

        next_node do |response|
          if response == 'yes'
            :outcome_61
          elsif response == 'no'
            :outcome_62
          end
        end
      end

      outcome :outcome_1 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_2 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_3 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_4 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_5 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_6 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      outcome :outcome_20 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_23 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_24 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      outcome :outcome_25 do
        precalculate :next_step_links do
          PhraseList.new(:ownerless_link)
        end
      end

      outcome :outcome_40 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_41 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_42 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_43 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_44 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_45 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      outcome :outcome_46 do
        precalculate :next_step_links do
          PhraseList.new(:ownerless_link)
        end
      end

      outcome :outcome_60 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_61 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_62 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_63 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_64 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_65 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end
      outcome :outcome_66 do
        precalculate :tbd_for_test_coverage do
          ''
        end
      end

      outcome :outcome_67 do
        precalculate :next_step_links do
          PhraseList.new(:ownerless_link)
        end
      end
    end
  end
end
