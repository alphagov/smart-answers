require_relative '../test_helper'

class SmartAnswerPresenterTest < ActionController::TestCase
  def setup
    request = stub("request", params: {})
    flow = stub("flow", name: "sample", slug: "sample")
    @presenter = SmartAnswerPresenter.new(request, flow)
  end

  should "detect the 'business' proposition when the artefact's business_proposition flag is true" do
    @presenter.stubs(:fetch_artefact)
      .with(slug: @presenter.flow.slug)
      .returns(stub("artefact", business_proposition: true))
    assert_equal "business", @presenter.proposition
  end

  should "detect the 'citizen' proposition when the artefact's business_proposition flag is false" do
    @presenter.stubs(:fetch_artefact)
      .with(slug: @presenter.flow.slug)
      .returns(stub("artefact", business_proposition: false))
    assert_equal "citizen", @presenter.proposition
  end
end