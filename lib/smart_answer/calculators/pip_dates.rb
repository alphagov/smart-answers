require 'uk_postcode'

module SmartAnswer::Calculators
  class PIPDates
    DLA_CUTOFF = Date.parse('2013-10-07')

    GROUP_65_CUTOFF = Date.parse('1949-04-08')
    MIDDLE_GROUP_CUTOFF = Date.parse('1998-04-07')
    
    def initialize(postcode = nil)
      self.postcode = postcode if postcode
    end

    attr_accessor :dla_end_date, :dob

    def postcode=(postcode_string)
      pc = UKPostcode.new(postcode_string)
      @postcode = pc
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

    def in_group_65?
      self.dob <= GROUP_65_CUTOFF
    end

    def in_middle_group?
      self.dob > GROUP_65_CUTOFF and self.dob < MIDDLE_GROUP_CUTOFF
    end

    def dla_continues?
      self.dla_end_date > DLA_CUTOFF
    end
  end
end
