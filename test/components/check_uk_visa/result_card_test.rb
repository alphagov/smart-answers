require "component_test_helper"

class ResultCardVisaTest < ComponentTestCase
  def component_name
    "check_uk_visa/result_card"
  end

  ATTRIBUTES = {
    "job_offer" => {
      "answer" => "Yes",
      "description" => "Your offer must be from a UK employer that's a registered sponsor for this visa",
    },
    "minimum_salary" => {
      "answer" => "Yes",
      "description" => "How much you need to earn depends on the work you do",
    },
    "english_knowledge" => {
      "answer" => "No",
    },
    "initial_visa_length" => {
      "answer" => "Up to 1 year",
    },
    "can_extend" => {
      "answer" => "No",
      "description" => "To stay longer, you may be able to switch to another visa",
    },
    "can_settle" => {
      "answer" => "No",
      "description" => "Settling means you can live permanently in the UK. If you successfully apply, you can use this status to apply for citizenship",
    },
  }.freeze

  calculator = SmartAnswer::Calculators::UkVisaCalculator.new

  test "fails to render when no data is given" do
    assert_raises do
      render_component({})
    end
  end

  test "does not render when no type is provided" do
    assert_raises do
      render_component({
        title: "Result card title",
        url: "www.gov.uk",
        attributes: ATTRIBUTES,
        calculator:,
      })
    end
  end

  test "does not render when no title is provided" do
    assert_raises do
      render_component({
        type: "Result card type",
        url: "www.gov.uk",
        attributes: ATTRIBUTES,
        calculator:,
      })
    end
  end

  test "does not render when no url is provided" do
    assert_raises do
      render_component({
        type: "Result card type",
        title: "Result card title",
        attributes: ATTRIBUTES,
        calculator:,
      })
    end
  end

  test "does not render when no attributes are provided" do
    assert_raises do
      render_component({
        type: "Result card type",
        title: "Result card title",
        url: "www.gov.uk",
        calculator:,
      })
    end
  end

  test "does not render when no calculator is provided" do
    assert_raises do
      render_component({
        type: "Result card type",
        title: "Result card title",
        url: "www.gov.uk",
        attributes: ATTRIBUTES,
      })
    end
  end

  test "does not render when only the description is provided" do
    assert_raises do
      render_component({ description: "Result card description" })
    end
  end

  test "renders a result card with the type, title, url and attributes" do
    render_component({
      type: "Visa type",
      title: "Result card title",
      url: "www.gov.uk",
      attributes: ATTRIBUTES,
      calculator:,
    })

    assert_select ".app-c-result-card" do
      assert_select ".govuk-heading-m", text: /\s*Result\s*card\s*title\s*/ do
        assert_select ".govuk-caption-m", text: "Visa type"
      end
      assert_select ".app-c-result-card__attribute", count: ATTRIBUTES.count
      assert_select ".app-c-result-card__link[href='www.gov.uk']", text: "Find out more about the Visa type"
    end
  end
end
