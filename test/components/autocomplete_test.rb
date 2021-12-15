require "component_test_helper"

class AutocompleteTest < ComponentTestCase
  def component_name
    "autocomplete"
  end

  test "does not render when no data is specified" do
    assert_empty render_component({})
  end

  test "does not render when no label is specified" do
    assert_empty render_component(
      options: ["United Kingdom", "United States"],
    )
  end

  test "does not render when no options are specified" do
    assert_empty render_component(
      label: "Countries",
    )
  end

  test "renders an input with a datalist" do
    render_component(
      id: "basic-autocomplete",
      label: "Countries",
      options: ["United Kingdom", "United States"],
    )

    assert_select ".govuk-label", text: "Countries", for: "basic-autocomplete"
    assert_select "input#basic-autocomplete"
    assert_select "datalist option[value='United Kingdom']"
    assert_select "datalist option[value='United States']"
  end

  tests "renders an input with a value" do
    render_component(
      label: "Countries",
      options: ["United Kingdom", "United States"],
      value: "Belgium",
    )

    assert_select ".app-c-autocomplete input[value='Belgium']"
  end

  tests "renders an input with a name" do
    render_component(
      label: "Countries",
      options: ["United Kingdom", "United States"],
      name: "custom-name",
    )

    assert_select "input[name='custom-name']"
  end

  tests "renders an input with an error" do
    render_component(
      label: "Countries",
      options: ["United Kingdom", "United States"],
      name: "custom-name",
      error_items: [
        {
          text: "There is a problem with this input",
        },
      ],
    )

    assert_select ".app-c-autocomplete .govuk-form-group--error"
    assert_select ".govuk-error-message", text: "There is a problem with this input"
  end
end
