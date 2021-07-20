require_relative "../test_helper"

class QueryParametersResponseStoreTest < ActiveSupport::TestCase
  context "#new" do
    should "not store parameters unless specified key" do
      responses = { k: "v", k2: "v2", k3: "v3" }
      response_store = QueryParametersResponseStore.new(
        query_parameters: responses,
        user_response_keys: [:k],
        additional_keys: [:k2],
      )

      assert_equal({ k: "v", k2: "v2" }, response_store.all)
    end
  end
end
