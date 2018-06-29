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
    @logger = Logger.new(STDOUT)
    @logger.stubs(:info)
    create_test_artefacts
    @flattener = MarriageAbroadOutcomeFlattener.new(
      "narnia",
      same_sex_wording: :civil_partnership,
      logger: @logger
    )
  end

  teardown do
    FileUtils.rm_rf(TEST_ARTEFACTS_PATH)
    FileUtils.rm_rf(OUTCOMES_PATH)
  end

  def create_test_artefacts
    FileUtils.mkdir_p("#{TEST_ARTEFACTS_PATH}/1/1")
    %w(same_sex.txt opposite_sex.txt).each do |filename|
      File.write("#{TEST_ARTEFACTS_PATH}/1/1/#{filename}", ARTEFACT_CONTENT)
    end
  end

  test "creates outcomes from test artefacts" do
    @flattener.flatten
    assert File.exist?("#{OUTCOMES_PATH}/1/1/_same_sex.erb"), "Same sex outcome was not created"
    assert File.exist?("#{OUTCOMES_PATH}/1/1/_opposite_sex.erb"), "Opposite sex outcome was not created"
  end

  test "creates a title partial" do
    @flattener.flatten
    assert File.exist?("#{OUTCOMES_PATH}/_title.govspeak.erb"), "Title partial was not created"
  end

  test "substitutes fees and payment info" do
    @flattener.flatten

    same_sex_outcome_content = IO.read("#{OUTCOMES_PATH}/1/1/_same_sex.erb")
    opposite_sex_outcome_content = IO.read("#{OUTCOMES_PATH}/1/1/_opposite_sex.erb")

    assert_match "render partial: 'consular_fees_table_items.govspeak.erb'", same_sex_outcome_content
    assert_match "render partial: 'how_to_pay.govspeak.erb'", same_sex_outcome_content
    assert_match "render partial: 'consular_fees_table_items.govspeak.erb'", opposite_sex_outcome_content
    assert_match "render partial: 'how_to_pay.govspeak.erb'", opposite_sex_outcome_content
  end

  test "allows different same-sex wording" do
    @same_sex_marriage_flattener = MarriageAbroadOutcomeFlattener.new(
      "narnia",
      same_sex_wording: :same_sex_marriage,
      logger: @logger,
    )

    @same_sex_marriage_flattener.flatten
    assert_match "Same-sex marriage in Narnia", IO.read("#{OUTCOMES_PATH}/_title.govspeak.erb")

    @civil_partnership_flattener = MarriageAbroadOutcomeFlattener.new(
      "narnia",
      same_sex_wording: :civil_partnership,
      logger: @logger,
    )

    @civil_partnership_flattener.flatten
    assert_match "Civil partnership in Narnia", IO.read("#{OUTCOMES_PATH}/_title.govspeak.erb")
  end
end
