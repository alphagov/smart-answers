module BenchmarkHolidayEntitlementABTestable
  BENCHMARKING_PATHS = [
    '/calculate-your-holiday-entitlement',
    '/calculate-your-holiday-entitlement/y/days-worked-per-week',
    '/calculate-your-holiday-entitlement/y/hours-worked-per-week',
    '/calculate-your-holiday-entitlement/y/shift-worker'
  ].freeze

  def should_show_holiday_entitlement_variant?
    # Use GOVUK-ABTest-BenchmarkALDescription1=B header in dev to test this
    benchmark_holiday_entitlement_variant.variant_b? &&
      is_holiday_entitlement_tested_path?
  end

  def is_holiday_entitlement_tested_path?
    BENCHMARKING_PATHS.include? request.path
  end

  def benchmark_holiday_entitlement_variant
    @benchmark_holiday_entitlement_variant ||= benchmarking_holiday_entitlement_ab_test.requested_variant request.headers
  end

  def set_benchmark_holiday_entitlement_response_header
    benchmark_holiday_entitlement_variant.configure_response response
  end

  def self.included(base)
    base.helper_method :benchmark_holiday_entitlement_variant
  end

private

  def benchmarking_holiday_entitlement_ab_test
    @description_ab_test ||= GovukAbTesting::AbTest.new("BenchmarkALDescription1", dimension: 63)
  end
end
