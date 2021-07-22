module FixtureMethods
  def fixture_file(filename)
    Rails.root.join("test/fixtures/#{filename}")
  end

  def read_fixture_file(filename)
    File.read(fixture_file(filename))
  end

  def fixture_flows_path
    Rails.root.join("test/fixtures/flows")
  end

  def require_fixture_flows
    Dir[fixture_flows_path.join("*.rb")].map { |path| require path }
  end

  def setup_fixture_flows
    stub_request(:get, %r{#{Plek.new.find("content-store")}/content/(.*)})
      .to_return(status: 404, body: {}.to_json)

    require_fixture_flows

    SmartAnswer::FlowRegistry.reset_instance(smart_answer_load_path: fixture_flows_path)
  end

  def teardown_fixture_flows
    SmartAnswer::FlowRegistry.reset_instance
  end
end
