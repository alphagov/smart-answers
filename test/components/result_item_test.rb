require "component_test_helper"

class ResultItemTest < ComponentTestCase
  def component_name
    "result-item"
  end

  test "fails to render when no data is given" do
    assert_raises do
      render_component({})
    end
  end

  test "fails to render when no title is specified" do
    assert_raises do
      render_component({
        url: "www.gov.uk",
        description: "Result item description",
      })
    end
  end

  test "fails to render when no URL is specified" do
    assert_raises do
      render_component({
        title: "Result item title",
        description: "Result item description",
      })
    end
  end

  test "fails to render when no description is specified" do
    assert_raises do
      render_component({
        title: "Result item title",
        url: "www.gov.uk",
      })
    end
  end

  test "renders a result item in the default style" do
    render_component({
      title: "Result item title",
      url: "www.gov.uk",
      description: "Result item description",
      highlighted: false,
    })

    assert_select ".app-c-result-item", true
    assert_select ".app-c-result-item .app-c-result-item--highlighted", false
    assert_select ".app-c-result-item .govuk-link[href='www.gov.uk']", text: "Result item title (opens in new tab)"
    assert_select ".app-c-result-item .govuk-body", text: "Result item description"
  end

  test "renders a result item in the highlighted style" do
    render_component({
      title: "Result item title",
      url: "www.gov.uk",
      description: "Result item description",
      highlighted: true,
    })

    assert_select ".app-c-result-item", true
    assert_select ".app-c-result-item.app-c-result-item--highlighted", true
    assert_select ".app-c-result-item .govuk-link[href='www.gov.uk']", text: "Result item title (opens in new tab)"
    assert_select ".app-c-result-item .govuk-body", text: "Result item description"
  end

  test "the track action for google analytics is formatted as [group_index.result_index]" do
    render_component({
      title: "Result item Title",
      url: "gov.uk",
      description: "Result item description",
      group_index: 100,
      result_index: 200,
    })

    assert_select ".app-c-result-item .govuk-link[data-track-action='100.200']", true
  end
end
