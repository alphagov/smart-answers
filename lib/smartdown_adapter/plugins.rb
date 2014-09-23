module SmartdownAdapter
  module Plugins
    class YearsUntilTrainingForgotten
      def self.key
        "years_until_training_forgotten"
      end

      def call(training_date)
        (Date.parse(training_date).year + 20) - Time.zone.now.year
      end
    end
    class EarliestStart
      def self.key
        "earliest_start"
      end
      def call(placement_date)
        "TODO_earliest_start"
      end
    end
    class EndOfAdoptionPay
      def self.key
        "end_of_adoption_pay"
      end
      def call(date_leave_1)
        "TODO_end_of_adoption_pay"
      end
    end
    class EndOfAdditionalLeave
      def self.key
        "end_of_additional_leave"
      end
      def call(date_leave_1)
        "TODO_end_of_additional_leave"
      end
    end
    class EndOfAdditionalPaternityLeave
      def self.key
        "end_of_additional_paternity_leave"
      end
      def call(date)
        "TODO_end_of_additional_paternity_leave"
      end
    end
    class EndOfMaternityLeave
      def self.key
        "end_of_maternity_leave"
      end
      def call(date_leave_1)
        "TODO_end_of_maternity_leave"
      end
    end
    class EndOfOrdinaryLeave
      def self.key
        "end_of_ordinary_leave"
      end
      def call(date_leave_1)
        "TODO_end_of_ordinary_leave"
      end
    end
    class EndOfPaternityLeave
      def self.key
        "end_of_paternity_leave"
      end
      def call(date_leave_2)
        "TODO_end_of_paternity_leave"
      end
    end
    class EndOfPay
      def self.key
        "end_of_pay"
      end
      def call(date)
        "TODO_end_of_pay"
      end
    end
    class EndOfSharedParentalLeave
      def self.key
        "end_of_shared_parental_leave"
      end
      def call(date)
        "TODO_end_of_shared_parental_leave"
      end
    end
    class LatestPatLeave
      def self.key
        "latest_pat_leave"
      end
      def call(date)
        "TODO_latest_pat_leave"
      end
    end
    class MinusThreeDays
      def self.key
        "minus_three_days"
      end
      def call(date)
        "TODO_minus_three_days"
      end
    end
    class NoticeMaternityAllowance
      def self.key
        "notice_maternity_allowance"
      end
      def call
        "TODO_notice_maternity_allowance"
      end
    end
    class PaternityLeaveNoticeDate
      def self.key
        "paternity_leave_notice_date"
      end
      def call(date)
        "TODO_paternity_leave_notice_date"
      end
    end
    class PaternityPayNoticeDate
      def self.key
        "paternity_pay_notice_date"
      end
      def call(date_leave_2)
        "TODO_paternity_pay_notice_date"
      end
    end
    class PeriodOfMaternityAllowance
      def self.key
        "period_of_maternity_allowance"
      end
      def call
        "TODO_period_of_maternity_allowance"
      end
    end
    class QualifyingWeek
      def self.key
        "qualifying_week"
      end
      def call(match_date)
        "TODO_qualifying_week"
      end
    end
    class RateOfPaternityPay
      def self.key
        "rate_of_paternity_pay"
      end
      def call(salary_2)
        "TODO_rate_of_paternity_pay"
      end
    end
    class RateOfPay
      def self.key
        "rate_of_pay"
      end
      def call
        "TODO_rate_of_pay"
      end
    end
    class RateOfSap
      def self.key
        "rate_of_sap"
      end
      def call(salary_1)
        "TODO_rate_of_sap"
      end
    end
    class RateOfSmp
      def self.key
        "rate_of_smp"
      end
      def call(salary_1)
        "TODO_rate_of_smp"
      end
    end
    class StartOfAdditionalLeave
      def self.key
        "start_of_additional_leave"
      end
      def call(date_leave_1)
        "TODO_start_of_additional_leave"
      end
    end
    class StartOfAdditionalPaternityLeave
      def self.key
        "start_of_additional_paternity_leave"
      end
      def call(date)
        "TODO_start_of_additional_paternity_leave"
      end
    end
    class TotalMaternityAllowance
      def self.key
        "total_maternity_allowance"
      end
      def call
        "TODO_total_maternity_allowance"
      end
    end
    class TotalSap
      def self.key
        "total_sap"
      end
      def call(salary_1)
        "TODO_total_sap"
      end
    end
  end
end
