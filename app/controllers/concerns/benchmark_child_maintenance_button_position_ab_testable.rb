module BenchmarkChildMaintenanceButtonPositionABTestable
  BENCHMARKING_PATHS = ['/calculate-your-child-maintenance'].freeze

  def should_show_button_position_variant?
    # Use GOVUK-ABTest-BenchmarkCmButton1=B header in dev to test this
    benchmark_button_position_variant.variant_b? &&
      is_button_position_tested_path?
  end

  def is_button_position_tested_path?
    BENCHMARKING_PATHS.include? request.path
  end

  def benchmark_button_position_variant
    @benchmark_button_position_variant ||= benchmarking_button_position_ab_test.requested_variant request.headers
  end

  def set_benchmark_button_position_response_header
    benchmark_button_position_variant.configure_response response
  end

  def self.included(base)
    base.helper_method :benchmark_button_position_variant
  end

private

  def benchmarking_button_position_ab_test
    @button_ab_test ||= GovukAbTesting::AbTest.new("BenchmarkCmButton1", dimension: 64)
  end
end
