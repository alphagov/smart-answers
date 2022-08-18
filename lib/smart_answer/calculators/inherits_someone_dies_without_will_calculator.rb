module SmartAnswer::Calculators
  class InheritsSomeoneDiesWithoutWillCalculator
    attr_accessor :region, :next_steps, :partner, :estate_over_250000, :estate_over_270000, :children, :parents,
                  :siblings, :siblings_including_mixed_parents, :grandparents, :aunts_or_uncles, :half_siblings,
                  :half_aunts_or_uncles, :great_aunts_or_uncles, :more_than_one_child

    def estate_over_250000?
      estate_over_250000 == "yes"
    end

    def estate_over_270000?
      estate_over_270000 == "yes"
    end

    def children?
      children == "yes"
    end

    def partner?
      partner == "yes"
    end

    def parents?
      parents == "yes"
    end

    def siblings?
      siblings == "yes"
    end

    def siblings_including_mixed_parents?
      siblings_including_mixed_parents == "yes"
    end

    def grandparents?
      grandparents == "yes"
    end

    def aunts_or_uncles?
      aunts_or_uncles == "yes"
    end

    def half_siblings?
      half_siblings == "yes"
    end

    def half_aunts_or_uncles?
      half_aunts_or_uncles == "yes"
    end

    def great_aunts_or_uncles?
      great_aunts_or_uncles == "yes"
    end

    def more_than_one_child?
      more_than_one_child == "yes"
    end

    def hint_needed_for_half_relations?
      region == "england-and-wales"
    end
  end
end
