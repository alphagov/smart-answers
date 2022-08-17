require "component_test_helper"

class ResultSectionsTest < ComponentTestCase
  def component_name
    "result-sections"
  end

  TOPICS = {
    "Tax" => [
      {
        "id" => "r1",
        "title" => "Register for Corporation Tax",
        "description" => "You need to register within 3 months of starting to do business, if you have not done so already.",
        "url" => "/corporation-tax",
        "topic" => "Tax",
        "group" => "Things you need to do next",
      },
      {
        "id" => "r4",
        "title" => "Check if you need to send a Self Assessment",
        "description" => "You might need to send a tax return if you have any untaxed income, such as dividends.",
        "url" => "/check-if-you-need-tax-return",
        "topic" => "Tax",
        "group" => "Things you need to do next",
      },
    ],
    "Insurance" => [
      {
        "id" => "r3",
        "title" => "Check if you need insurance",
        "description" => "There are different types of insurance you might need, depending on your area of business.",
        "url" => "www.gov.uk",
        "topic" => "Insurance",
        "group" => "Things you need to do next",
      },
    ],
  }.freeze

  test "the fails to render when no data is given" do
    assert_raises do
      render_component({})
    end
  end

  test "renders a result section containing result items" do
    render_component({
      topics: TOPICS,
    })

    assert_select ".app-c-result-sections" do
      assert_select ".app-c-result-sections__section:nth-child(2)" do
        assert_select "h3.govuk-heading-m", text: "Insurance"
        assert_select ".app-c-result-item" do
          assert_select ".app-c-result-item .govuk-link[href='www.gov.uk']", text: "Check if you need insurance (opens in new tab)"
          assert_select ".app-c-result-item .govuk-body", text: "There are different types of insurance you might need, depending on your area of business."
        end
      end
    end
  end

  test "renders a result item in the default style" do
    render_component({
      topics: TOPICS,
      highlighted: false,
    })

    assert_select ".app-c-result-sections" do
      assert_select ".app-c-result-item", true
      assert_select ".app-c-result-item .app-c-result-item--highlighted", false
    end
  end

  test "renders a result item in the highlighted style" do
    render_component({
      topics: TOPICS,
      highlighted: true,
    })

    assert_select ".app-c-result-sections" do
      assert_select ".app-c-result-item.app-c-result-item--highlighted", true
    end
  end

  test "result_index is incremented for the google analytics track action" do
    render_component({
      topics: TOPICS,
    })

    assert_select ".app-c-result-sections" do
      assert_select ".app-c-result-sections__section:nth-child(1)" do
        assert_select ".app-c-result-item:nth-child(3) .govuk-link[data-track-action='1.2']"
      end
    end
  end
end
