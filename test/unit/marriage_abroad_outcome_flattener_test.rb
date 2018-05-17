require "test_helper"

class MarriageAbroadOutcomeFlattenerTest < ActiveSupport::TestCase
  TEST_ARTEFACTS_PATH = "test/artefacts/marriage-abroad/narnia".freeze
  OUTCOMES_PATH = "lib/smart_answer_flows/marriage-abroad/outcomes/countries/narnia".freeze
  ARTEFACT_CONTENT = <<~CONTENT.freeze
    This will be deleted

    # The start

    Something something wardrobe.

    Service | Fee
    -|-
    Witch Removal | £20

    Blah blah fawns.

    ^You can only pay by narnian express

    Other cards will not be accepted.^

    # The end.
  CONTENT

  # we create and destroy the artefacts around every test because if
  # tests from this suite are interleaved with regression tests, the
  # regression tests may fail because of the unexpected artefact
  # files.
  setup do
    logger = Logger.new(STDOUT)
    logger.stubs(:info)
    create_test_artefacts
    described_class.new("narnia", logger).flatten
  end

  teardown do
    FileUtils.rm_rf(TEST_ARTEFACTS_PATH)
    FileUtils.rm_rf(OUTCOMES_PATH)
  end

  def described_class
    MarriageAbroadOutcomeFlattener
  end

  def create_test_artefacts
    FileUtils.mkdir_p("#{TEST_ARTEFACTS_PATH}/1/1")
    %w(same_sex.txt opposite_sex.txt).each do |filename|
      File.write("#{TEST_ARTEFACTS_PATH}/1/1/#{filename}", ARTEFACT_CONTENT)
    end
  end

  test "creates outcomes from test artefacts" do
    assert File.exist?("#{OUTCOMES_PATH}/1/1/_same_sex.erb"), "Same sex outcome was not created"
    assert File.exist?("#{OUTCOMES_PATH}/1/1/_opposite_sex.erb"), "Opposite sex outcome was not created"
  end

  test "creates a title partial" do
    assert File.exist?("#{OUTCOMES_PATH}/_title.govspeak.erb"), "Title partial was not created"
  end

  test "substitutes fees and payment info" do
    same_sex_outcome_content = IO.read("#{OUTCOMES_PATH}/1/1/_same_sex.erb")
    opposite_sex_outcome_content = IO.read("#{OUTCOMES_PATH}/1/1/_opposite_sex.erb")

    assert_match "render partial: 'consular_fees_table_items.govspeak.erb'", same_sex_outcome_content
    assert_match "render partial: 'how_to_pay.govspeak.erb'", same_sex_outcome_content
    assert_match "render partial: 'consular_fees_table_items.govspeak.erb'", opposite_sex_outcome_content
    assert_match "render partial: 'how_to_pay.govspeak.erb'", opposite_sex_outcome_content
  end
end
