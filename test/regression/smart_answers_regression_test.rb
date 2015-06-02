require_relative "../test_helper"
require 'gds_api/test_helpers/content_api'
require 'gds_api/test_helpers/worldwide'

class SmartAnswerResponsesAndExpectedResultsTest < ActionController::TestCase
  self.i_suck_and_my_tests_are_order_dependent!
  RUN_ME_LAST = 'zzzzzzzzzzz run me last'

  include GdsApi::TestHelpers::ContentApi
  include GdsApi::TestHelpers::Worldwide

  tests SmartAnswersController

  SmartAnswerTestHelper.responses_and_expected_results.each do |file|
    filename  = File.basename(file, '.yml')
    flow_name = filename[/(.*)-responses-and-expected-results/, 1]

    smart_answer_helper = SmartAnswerTestHelper.new(flow_name)

    next unless smart_answer_helper.run_regression_tests?

    smart_answer_helper.delete_saved_output_files
    responses_and_expected_results = smart_answer_helper.read_responses_and_expected_results

    context "Smart Answer: #{flow_name}" do
      setup do
        Timecop.freeze(Date.parse('2015-01-01'))
        stub_content_api_default_artefact
        WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).to_return(body: File.open(fixture_file('bank_holidays.json')))

        setup_worldwide_locations
      end

      teardown do
        Timecop.return
      end

      should "have checksum data" do
        message = []
        message << "Expected #{smart_answer_helper.files_checksum_path} to exist"
        message << "Use the generate-checksums-for-smart-answer script to create it"
        assert_equal true, smart_answer_helper.files_checksum_data_exists?, message.join('. ')
      end

      should "have up to date checksum data" do
        message = []
        message << "Expected #{smart_answer_helper.files_checksum_path} to contain up to date data"
        message << "Use the generate-checksums-for-smart-answer script to update it"
        assert_equal false, smart_answer_helper.files_checksum_data_needs_updating?, message.join('. ')
      end

      should "ensure all nodes are being exercised" do
        flow = SmartAnswer::FlowRegistry.instance.find(flow_name)

        nodes_exercised_in_test = responses_and_expected_results.inject([]) do |array, responses_and_expected_results|
          current_node = responses_and_expected_results[:current_node]
          next_node    = responses_and_expected_results[:next_node]
          array << current_node unless array.include?(current_node)
          array << next_node unless array.include?(next_node)
          array
        end

        unexercised_nodes = flow.nodes.map(&:name) - nodes_exercised_in_test
        assert_equal true, unexercised_nodes.empty?, "Not all nodes are being exercised: #{unexercised_nodes.sort}"
      end

      responses_and_expected_results.each do |responses_and_expected_node|
        responses    = responses_and_expected_node[:responses]
        outcome_node = responses_and_expected_node[:outcome_node]

        if outcome_node
          should "render and save output for responses: #{responses.join(', ')}" do
            get :show, id: flow_name, started: 'y', responses: responses

            path_to_output = smart_answer_helper.save_output(responses, response)

            diff_output = `git diff #{path_to_output}`
            assert_equal '', diff_output
          end
        end
      end

      should "#{RUN_ME_LAST} and generate the same set of output files" do
        diff_output = `git diff --stat -- #{smart_answer_helper.path_to_outputs_for_flow}`
        assert_equal '', diff_output, "Unexpected difference in outputs for flow:"
      end
    end
  end

  private

  def setup_worldwide_locations
    location_slugs = Dir[fixture_file('worldwide/*_organisations.json')].map do |path|
      File.basename(path, ".json").split("_").first
    end
    worldwide_api_has_locations(location_slugs)
    location_slugs.each do |location|
      json = read_fixture_file("worldwide/#{location}_organisations.json")
      worldwide_api_has_organisations_for_location(location, json)
    end
  end
end
