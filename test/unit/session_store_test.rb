require_relative "../test_helper"

class SessionStoreTest < ActiveSupport::TestCase
  should "be enabled" do
    assert SmartAnswers::Application.config.session_store
  end
end
