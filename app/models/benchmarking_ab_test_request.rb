class BenchmarkingAbTestRequest
  attr_accessor :requested_variant

  delegate :analytics_meta_tag, to: :requested_variant

  def initialize(request)
    dimension = Rails.application.config.benchmarking_ab_test_dimension
    ab_test = GovukAbTesting::AbTest.new(
      "Benchmarking",
      dimension: dimension
    )
    @requested_variant = ab_test.requested_variant(request.headers)
  end

  def in_benchmarking?
    requested_variant.variant_b?
  end

  def set_response_vary_header(response)
    requested_variant.configure_response(response)
  end
end
