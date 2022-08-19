require "component_test_helper"

class ResultCardTest < ComponentTestCase
  def component_name
    "result-card"
  end

  test "fails to render when no data is given" do
    assert_raises do
      render_component({})
    end
  end

  test "does not render when no title is provided" do
    assert_raises do
      render_component({
        url: "www.gov.uk",
        url_text: "GOV.UK",
        url_track_action: "Smart Answer Flow Name",
      })
    end
  end

  test "does not render when no url is provided" do
    assert_raises do
      render_component({
        title: "Result card title",
        url_text: "GOV.UK",
        url_track_action: "Smart Answer Flow Name",
      })
    end
  end

  test "does not render when no url_text is provided" do
    assert_raises do
      render_component({
        title: "Result card title",
        url: "www.gov.uk",
        url_track_action: "Smart Answer Flow Name",
      })
    end
  end

  test "does not render when no url_track_action is provided" do
    assert_raises do
      render_component({
        title: "Result card title",
        url: "www.gov.uk",
        url_text: "GOV.UK",
      })
    end
  end

  test "does not render when only the description is provided" do
    assert_raises do
      render_component({ description: "Result card description" })
    end
  end

  test "renders a result card with only the title and url with tracking data" do
    render_component({
      title: "Result card title",
      description: nil,
      url: "www.gov.uk",
      url_text: "GOV.UK",
      url_track_action: "Smart Answer Flow Name",
    })

    assert_select ".app-c-result-card" do
      assert_select ".gem-c-heading", text: "Result card title"
      assert_select ".app-c-result-card__link[href='www.gov.uk']", text: "GOV.UK"
      assert_select ".app-c-result-card__link[data-track-action='Smart Answer Flow Name']", true
      assert_select ".app-c-result-card__description", false
    end
  end

  test "renders a result card with the title, description and url with tracking data" do
    render_component({
      title: "Result card title",
      description: "Result card description",
      url: "www.gov.uk",
      url_text: "GOV.UK",
      url_track_action: "Smart Answer Flow Name",
    })

    assert_select ".app-c-result-card" do
      assert_select ".gem-c-heading", text: "Result card title"
      assert_select ".app-c-result-card__link[href='www.gov.uk']", text: "GOV.UK"
      assert_select ".app-c-result-card__link[data-track-action='Smart Answer Flow Name']", true
      assert_select ".app-c-result-card__description", text: "Result card description"
    end
  end
end
