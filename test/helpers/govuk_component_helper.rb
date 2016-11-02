def test_presence_of_govuk_components(expected)
  html_document.css('test-govuk-component').map(&:values).flatten.each do |found_component|
    assert expected.include?(found_component)
  end
end

def stub_content_store_component_calls
  stub_request(:get, %r{#{Plek.new.find("static")}/templates/locales(.*)}).to_return(body: {}.to_json)
  stub_request(:get, %r{#{Plek.new.find("content-store")}/content/(.*)}).to_return(body: {}.to_json)
end
