module BenchmarkInlineLinkABTestable
  BENCHMARKING_PATHS = ['/calculate-your-child-maintenance'].freeze

  def should_show_benchmarking_variant?
    # Use GOVUK-ABTest-BenchmarkInlineLink=B header in dev to test this
    benchmark_inline_link_variant.variant_b? &&
      is_benchmarking_tested_path?
  end

  def is_benchmarking_tested_path?
    BENCHMARKING_PATHS.include? request.path
  end

  def benchmark_inline_link_variant
    @benchmark_inline_link_variant ||= benchmarking_ab_test.requested_variant request.headers
  end

  def set_benchmark_inline_links_response_header
    benchmark_inline_link_variant.configure_response response
  end

  def self.included(base)
    base.helper_method :benchmark_inline_link_variant
  end

private

  def benchmarking_ab_test
    @ab_test ||= GovukAbTesting::AbTest.new("BenchmarkInlineLink", dimension: 43)
  end
end
