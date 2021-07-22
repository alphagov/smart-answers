class QueryParametersResponseStore < ResponseStore
  def initialize(query_parameters:, user_response_keys:, additional_keys:)
    allowable_keys = user_response_keys + additional_keys

    super(responses: query_parameters.slice(*allowable_keys),
          user_response_keys: user_response_keys,
          additional_keys: additional_keys)
  end
end
