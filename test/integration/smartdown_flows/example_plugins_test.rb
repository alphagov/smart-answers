require 'integration_test_helper'

class ExamplePluginsTest < ActionDispatch::IntegrationTest
  def setup
    use_test_smartdown_flow_fixtures
    SmartdownAdapter::PluginFactory.reset_plugins_for('example-plugins')
    stub_content_api_default_artefact
  end

  def teardown
    stop_using_test_smartdown_flow_fixtures
  end

  test 'shows example of plugins in use' do
    visit smart_answer_path(id: 'example-plugins')
    click_on 'Start now'
    fill_in "£", with: "1000"
    select "month", from: 'per'
    click_on "Next step"

    assert page.has_content?("If you were luckier, you would earn 120000 per year.")
  end
end
