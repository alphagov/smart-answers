require_relative '../test_helper'
require_relative '../helpers/fixture_flows_helper'
require_relative '../fixtures/smart_answer_flows/data-partial-sample'
require 'gds_api/test_helpers/content_store'

class SmartAnswersControllerDebugPartialTemplatePathTest < ActionController::TestCase
  tests SmartAnswersController

  include FixtureFlowsHelper
  include GdsApi::TestHelpers::ContentStore

  def setup
    setup_fixture_flows
    registry = SmartAnswer::FlowRegistry.instance
    @template_directory = registry.load_path
    Rails.application.config.stubs(:debug_partials).returns(true)
  end

  def teardown
    teardown_fixture_flows
  end

  context 'rendering outcome page including HTML partial template' do
    setup do
      get :show, id: 'data-partial-sample', started: 'y', responses: 'data_partial_with_array'
    end

    should 'wrap partial with div' do
      assert_select 'div[data-debug-partial-template-path] .embassies'
    end

    should 'include element with debug-partial-template-path data attribute' do
      template_name = 'data_partials/_array_partial.html.erb'
      template_path = relative_template_path(template_name)
      assert_select "*[data-debug-partial-template-path=?]", template_path
    end
  end

  context 'rendering outcome page including govspeak partial template' do
    setup do
      get :show, id: 'data-partial-sample', started: 'y', responses: 'data_partial_with_scalar'
    end

    should 'wrap partial with div' do
      assert_select 'div[data-debug-partial-template-path]', text: /An address/
    end

    should 'include element with debug-partial-template-path data attribute' do
      template_name = 'data_partials/_scalar_partial.govspeak.erb'
      template_path = relative_template_path(template_name)
      assert_select "*[data-debug-partial-template-path=?]", template_path
    end

    should 'process govspeak in partial' do
      assert_select 'div[data-debug-partial-template-path]' do
        assert_select 'h2', text: 'An address'
        assert_select '.address', text: /Pulteney Street/
      end
    end
  end

  def relative_template_path(template_name)
    @template_directory.join(template_name).relative_path_from(Rails.root).to_s
  end
end
