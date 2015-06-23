require_relative '../test_helper'

class SessionStoreTest < ActiveSupport::TestCase
  should 'be disabled' do
    assert_nil SmartAnswers::Application.config.session_store
  end
end
