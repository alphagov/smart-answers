module BenchmarkChildMaintenanceTitleABTestable
  BENCHMARKING_PATHS = ['/calculate-your-child-maintenance'].freeze

  def should_show_benchmarking_variant?
    # Use GOVUK-ABTest-BenchmarkCmTitle1=B header in dev to test this
    benchmark_child_maintenance_title_variant.variant_b? &&
      is_benchmarking_tested_path?
  end

  def is_benchmarking_tested_path?
    BENCHMARKING_PATHS.include? request.path
  end

  def benchmark_child_maintenance_title_variant
    @benchmark_child_maintenance_title_variant ||= benchmarking_ab_test.requested_variant request.headers
  end

  def set_benchmark_child_maintenance_title_response_header
    benchmark_child_maintenance_title_variant.configure_response response
  end

  def self.included(base)
    base.helper_method :benchmark_child_maintenance_title_variant
  end

private

  def benchmarking_ab_test
    @ab_test ||= GovukAbTesting::AbTest.new("BenchmarkCmTitle2", dimension: 46)
  end
end
