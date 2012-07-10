# encoding: UTF-8
require_relative 'engine_test_helper'

class ContactListsAndPlacesTest < EngineIntegrationTest
  
  should "output contact-lists correctly" do
    visit "/contact-list-and-places-sample/y/contact_list"

    within '.result-info' do
      within('h2.result-title') { assert_page_has_content "Some random embasies" }

      # the 1st child is the .summary div (yes, that's how nth-child works...)
      within '.contact:nth-child(2)' do
        assert_page_has_content "British High Commission"
        assert_page_has_content "Consular Section"
        assert_page_has_content "Commonwealth Avenue"
        assert_page_has_content "Yarralumla"
        assert_page_has_content "ACT 2600"
        assert_page_has_content "(+61) (0) 2 6270 6666"
      end

      within '.contact:nth-child(3)' do
        assert_page_has_content "444-446 Pulteney Street"
        assert_page_has_content "Adelaide"
        assert_page_has_content "SA 5000"
      end

      within '.contact:nth-child(4)' do
        assert_page_has_content "British High Commission"
        assert_page_has_content "44 Hill Street"
        assert_page_has_content "Wellington 6011"
        assert_page_has_content "P O Box 1812"
        assert_page_has_content "Wellington 6140, Wellington"
        assert_page_has_content "(+64) (0) 9 6270 1234"
      end
    end
  end

  should "handle places correctly" do
    pending
  end
end
