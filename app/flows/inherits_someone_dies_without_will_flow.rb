class InheritsSomeoneDiesWithoutWillFlow < SmartAnswer::Flow
  def define
    content_id "1f75de31-1f07-4c68-b1ab-8330b1ee8670"
    name "inherits-someone-dies-without-will"
    status :published

    # The case & if blocks in this file are organised to be read in the same order
    # as the flow chart rather than to minimise repetition.

    # Q1
    radio :region? do
      option :"england-and-wales"
      option :scotland
      option :"northern-ireland"
      option :"outside-uk"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::InheritsSomeoneDiesWithoutWillCalculator.new
        calculator.region = response
        calculator.next_steps = %i[wills_link inheritance_link]
      end

      next_node do
        if calculator.region == "outside-uk"
          outcome :outcome_68
        else
          question :partner?
        end
      end
    end

    # Q2
    radio :partner? do
      option :yes
      option :no

      on_response do |response|
        calculator.partner = response
      end

      next_node do
        case calculator.region
        when "england-and-wales"
          if calculator.partner?
            question :date_of_death?
          else
            question :children?
          end
        when "northern-ireland"
          if calculator.partner?
            question :estate_over_250000?
          else
            question :children?
          end
        when "scotland"
          question :children?
        end
      end
    end

    # Q3 (England and Wales)
    radio :date_of_death? do
      option :"before-oct-2014"
      option :"oct-2014-feb-2020"
      option :"feb-2020-jul-2023"
      option :"after-jul-2023"

      on_response do |response|
        calculator.date_of_death = response
      end

      next_node do
        question :children?
      end
    end

    # Q3 (Ireland)
    radio :estate_over_250000? do
      option :yes
      option :no

      on_response do |response|
        calculator.estate_over_250000 = response
        calculator.next_steps = [:wills_link] unless calculator.estate_over_250000?
      end

      next_node do
        if calculator.estate_over_250000?
          question :children?
        else
          outcome :outcome_60
        end
      end
    end

    # Q4
    radio :children? do
      option :yes
      option :no

      on_response do |response|
        calculator.children = response
      end

      next_node do
        case calculator.region
        when "england-and-wales"
          if calculator.partner?
            case calculator.date_of_death
            when "before-oct-2014"
              if calculator.children?
                outcome :outcome_10
              else
                outcome :outcome_11
              end
            when "oct-2014-feb-2020"
              if calculator.children?
                outcome :outcome_12
              else
                outcome :outcome_14
              end
            when "feb-2020-jul-2023"
              if calculator.children?
                outcome :outcome_13
              else
                outcome :outcome_14
              end
            when "after-jul-2023"
              if calculator.children?
                outcome :outcome_15
              else
                outcome :outcome_14
              end
            end
          elsif calculator.children?
            outcome :outcome_2
          else
            question :parents?
          end
        when "scotland"
          if calculator.partner?
            if calculator.children?
              outcome :outcome_40
            else
              question :parents?
            end
          elsif calculator.children?
            outcome :outcome_2
          else
            question :parents?
          end
        when "northern-ireland"
          if calculator.partner?
            if calculator.children?
              question :more_than_one_child?
            else
              question :parents?
            end
          elsif calculator.children?
            outcome :outcome_66
          else
            question :parents?
          end
        end
      end
    end

    # Q5
    radio :parents? do
      option :yes
      option :no

      on_response do |response|
        calculator.parents = response
      end

      next_node do
        case calculator.region
        when "england-and-wales"
          if calculator.parents?
            outcome :outcome_3
          else
            question :siblings?
          end
        when "scotland"
          question :siblings?
        when "northern-ireland"
          if calculator.partner?
            if calculator.parents?
              outcome :outcome_63
            else
              question :siblings_including_mixed_parents?
            end
          elsif calculator.parents?
            outcome :outcome_3
          else
            question :siblings?
          end
        end
      end
    end

    # Q6
    radio :siblings? do
      option :yes
      option :no

      on_response do |response|
        calculator.siblings = response
      end

      next_node do
        case calculator.region
        when "england-and-wales"
          if calculator.siblings?
            outcome :outcome_4
          else
            question :half_siblings?
          end
        when "scotland"
          if calculator.partner?
            if calculator.parents?
              if calculator.siblings?
                outcome :outcome_43
              else
                outcome :outcome_42
              end
            elsif calculator.siblings?
              outcome :outcome_41
            else
              outcome :outcome_1
            end
          elsif calculator.parents?
            if calculator.siblings?
              outcome :outcome_44
            else
              outcome :outcome_3
            end
          elsif calculator.siblings?
            outcome :outcome_4
          else
            question :aunts_or_uncles?
          end
        when "northern-ireland"
          if calculator.siblings?
            outcome :outcome_4
          else
            question :grandparents?
          end
        end
      end
    end

    # Q61
    radio :siblings_including_mixed_parents? do
      option :yes
      option :no

      on_response do |response|
        calculator.siblings_including_mixed_parents = response
      end

      next_node do
        if calculator.siblings_including_mixed_parents?
          outcome :outcome_64
        else
          outcome :outcome_65
        end
      end
    end

    # Q7
    radio :grandparents? do
      option :yes
      option :no

      on_response do |response|
        calculator.grandparents = response
      end

      next_node do
        case calculator.region
        when "england-and-wales"
          if calculator.grandparents?
            outcome :outcome_5
          else
            question :aunts_or_uncles?
          end
        when "scotland"
          if calculator.grandparents?
            outcome :outcome_5
          else
            question :great_aunts_or_uncles?
          end
        when "northern-ireland"
          if calculator.grandparents?
            outcome :outcome_5
          else
            question :aunts_or_uncles?
          end
        end
      end
    end

    # Q8
    radio :aunts_or_uncles? do
      option :yes
      option :no

      on_response do |response|
        calculator.aunts_or_uncles = response
      end

      next_node do
        case calculator.region
        when "england-and-wales"
          if calculator.aunts_or_uncles?
            outcome :outcome_6
          else
            question :half_aunts_or_uncles?
          end
        when "scotland"
          if calculator.aunts_or_uncles?
            outcome :outcome_6
          else
            question :grandparents?
          end
        when "northern-ireland"
          if calculator.aunts_or_uncles?
            outcome :outcome_6
          else
            outcome :outcome_67
          end
        end
      end
    end

    # Q20
    radio :half_siblings? do
      option :yes
      option :no

      on_response do |response|
        calculator.half_siblings = response
      end

      next_node do
        if calculator.half_siblings?
          outcome :outcome_23
        else
          question :grandparents?
        end
      end
    end

    # Q21
    radio :half_aunts_or_uncles? do
      option :yes
      option :no

      on_response do |response|
        calculator.half_aunts_or_uncles = response
      end

      next_node do
        if calculator.half_aunts_or_uncles?
          outcome :outcome_24
        else
          outcome :outcome_25
        end
      end
    end

    # Q40
    radio :great_aunts_or_uncles? do
      option :yes
      option :no

      on_response do |response|
        calculator.great_aunts_or_uncles = response
      end

      next_node do
        if calculator.great_aunts_or_uncles?
          outcome :outcome_45
        else
          outcome :outcome_46
        end
      end
    end

    # Q60
    radio :more_than_one_child? do
      option :yes
      option :no

      on_response do |response|
        calculator.more_than_one_child = response
      end

      next_node do
        if calculator.more_than_one_child?
          outcome :outcome_61
        else
          outcome :outcome_62
        end
      end
    end

    outcome :outcome_1
    outcome :outcome_2
    outcome :outcome_3
    outcome :outcome_4
    outcome :outcome_5
    outcome :outcome_6

    outcome :outcome_10
    outcome :outcome_11
    outcome :outcome_12
    outcome :outcome_13
    outcome :outcome_14
    outcome :outcome_15

    outcome :outcome_23
    outcome :outcome_24
    outcome :outcome_25

    outcome :outcome_40
    outcome :outcome_41
    outcome :outcome_42
    outcome :outcome_43
    outcome :outcome_44
    outcome :outcome_45
    outcome :outcome_46

    outcome :outcome_60
    outcome :outcome_61
    outcome :outcome_62
    outcome :outcome_63
    outcome :outcome_64
    outcome :outcome_65
    outcome :outcome_66
    outcome :outcome_67

    outcome :outcome_68
  end
end
