require_relative 'engine_test_helper'

class DataPartialsTest < EngineIntegrationTest
  setup do
    SmartdownAdapter::Registry.reset_instance
  end

  should "output data partials correctly" do
    visit "/data-partial-sample/y/data_partial_with_scalar"

    within '.result-info' do
      within('h2.result-title') { assert_page_has_content "Data partial with scalar data" }

      assert page.has_selector?('p', text: "Some data that was passed through")

      assert page.has_selector?('h2', text: "An address")
      within '.address' do
        assert_page_has_content "444-446 Pulteney Street"
        assert_page_has_content "Adelaide"
        assert_page_has_content "SA 5000"
      end

      assert page.has_selector?('h2', text: "And a phone number")
      within '.contact' do
        assert_page_has_content "(+61) (0) 2 6270 8888"
      end
      assert page.has_selector?('p', text: "More markdown afterwards")
    end
  end

  should "work pass arrays of stuff through to the partial" do
    # This use case doesn't have any extra code, it's a common use case though
    # so worth being explicit about

    visit "/data-partial-sample/y/data_partial_with_array"

    within '.result-info' do
      within('h2.result-title') { assert_page_has_content "Data partial with array data" }

      assert page.has_selector?('p', text: "Some data that was passed through")

      within '.embassies' do
        assert page.has_selector?('.embassy', count: 2)
        within '.embassy:nth-child(1)' do
          assert page.has_selector?('h3', text: "Address")
          assert_page_has_content "British High Commission"
          assert_page_has_content "Consular Section"
          assert_page_has_content "Commonwealth Avenue"
          assert_page_has_content "Yarralumla"
          assert_page_has_content "ACT 2600"

   assert page.has_selector?('h3', text: "Phone")
          assert_page_has_content "(+61) (0) 2 6270 6666"
        end

        within '.embassy:nth-child(2)' do
          assert page.has_selector?('h3', text: "Address")
          assert_page_has_content "British High Commission"
          assert_page_has_content "44 Hill Street"
          assert_page_has_content "Wellington 6011"
          assert_page_has_content "P O Box 1812"
          assert_page_has_content "Wellington 6140"

   assert page.has_selector?('h3', text: "Phone")
          assert_page_has_content "(+64) (0) 9 6270 1234"
        end
      end

      assert page.has_selector?('p', text: "More markdown afterwards")
    end
  end
end
