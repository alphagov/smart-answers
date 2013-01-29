require 'uk_postcode'

module SmartAnswer::Calculators
  class PIPDates
    def postcode=(postcode_string)
      pc = UKPostcode.new(postcode_string)
      @postcode = pc
    end

    def valid_postcode?
      @postcode.full?
    end

    def in_selected_area?
      if %w(BL CA CW DH FY L M NE PR SR WA WN).include?(@postcode.area)
        true
      elsif @postcode.area == 'CH' and ! %w(5 6 7 8).include?(@postcode.district)
        true
      elsif @postcode.area == 'DL' and ! %w(6 7 8 9 10 11).include?(@postcode.district)
        true
      elsif @postcode.area == 'TS' and @postcode.district != '9'
        true
      elsif @postcode.area == 'LA'
        if @postcode.district == '2' and %w(7 8).include?(@postcode.sector)
          false
        elsif @postcode.district == '6' and %w(2 3).include?(@postcode.sector)
          false
        else 
          true
        end
      else
        false
      end
    end

    GROUP_65_CUTOFF = Date.parse('1949-04-08')
    MIDDLE_GROUP_CUTOFF = Date.parse('1997-04-08')
    TURNING_16_UPPER_CUTOFF = Date.parse('1997-10-07')

    attr_accessor :dob

    def in_group_65?
      self.dob <= GROUP_65_CUTOFF
    end

    def in_middle_group?
      self.dob > GROUP_65_CUTOFF and self.dob < MIDDLE_GROUP_CUTOFF
    end

    def turning_16_before_oct_2013?
      self.dob >= MIDDLE_GROUP_CUTOFF and self.dob < TURNING_16_UPPER_CUTOFF
    end
  end
end
