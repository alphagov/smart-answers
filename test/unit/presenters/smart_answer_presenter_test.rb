require_relative '../../test_helper'

class SmartAnswerPresenterTest < ActiveSupport::TestCase
  test 'should not append an empty element to the responses array if there is no response in the params' do
    params    = { next: true, response: nil }
    request   = stub(params: params)
    flow      = SmartAnswer::Flow.new
    presenter = SmartAnswerPresenter.new(request, flow)

    assert_equal [], presenter.all_responses
  end
end
