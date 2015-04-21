# encoding: UTF-8
require_relative 'engine_test_helper'
require 'gds_api/test_helpers/worldwide'

class CountryAndDateQuestionsTest < EngineIntegrationTest
  include GdsApi::TestHelpers::Worldwide

  with_and_without_javascript do
    setup do
      @location_slugs = %w(
        afghanistan angola aruba bangladesh belarus brazil brunei
        cambodia chad croatia denmark eritrea france ghana iceland
        japan laos luxembourg malta micronesia mozambique nicaragua
        panama portugal sao-tome-and-principe singapore south-korea
        sri-lanka uk-delegation-to-council-of-europe
        uk-delegation-to-organization-for-security-and-co-operation-in-europe
        united-kingdom venezuela vietnam)
      worldwide_api_has_locations(@location_slugs)
      Timecop.travel("2013-01-01")
    end

    should "handle country and date questions" do
      visit "/country-and-date-sample/y"

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "Which country do you live in?"
        end
      end
      within '.question-body' do
        assert page.has_select?("response")
        # Options above missing delegations and uk
        expected = %w(angola aruba bangladesh belarus brazil brunei
          cambodia chad croatia denmark eritrea france ghana iceland
          japan laos luxembourg malta micronesia mozambique nicaragua
          panama portugal sao-tome-and-principe singapore south-korea
          sri-lanka venezuela vietnam)
        actual = page.all('select option').map(&:value)
        assert_equal expected, actual
      end

      select "Belarus", from: "response"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus"

      within '.done-questions' do
        assert page.has_link?("Start again", href: '/country-and-date-sample')
        within 'tr.section:nth-child(1)' do
          within 'td.previous-question-title' do
            assert_page_has_content "Which country do you live in?"
          end
          within('td.previous-question-body') { assert_page_has_content "Belarus" }
          within('.link-right') { assert page.has_link?("Change", href: "/country-and-date-sample/y?previous_response=belarus") }
        end
      end

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "What date did you move there?"
        end
      end

      within '.question-body' do
        # TODO Check options for dates
        assert page.has_select? 'Day'
        assert page.has_select? 'Month'
        assert page.has_select? 'Year'
      end

      select "5", from: "Day"
      select "May", from: "Month"
      select "1975", from: "Year"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus/1975-05-05"

      within '.done-questions' do
        assert page.has_link?("Start again", href: '/country-and-date-sample')
        within 'tr.section:nth-child(1)' do
          within 'td.previous-question-title' do
            assert_page_has_content "Which country do you live in?"
          end
          within('td.previous-question-body') { assert_page_has_content "Belarus" }
          within('.link-right') { assert page.has_link?("Change", href: "/country-and-date-sample/y?previous_response=belarus") }
        end

        within 'tr.section:nth-child(2)' do
          within 'td.previous-question-title' do
            assert_page_has_content "What date did you move there?"
          end

          within('td.previous-question-body') { assert_page_has_content "5 May 1975" }
          within('.link-right') { assert page.has_link?("Change", href: "/country-and-date-sample/y/belarus?previous_response=1975-05-05") }
        end
      end

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "Which country were you born in?"
        end
      end
      within '.question-body' do
        assert page.has_select?("response")
        # Options above excluding delegations
        expected = %w(afghanistan angola aruba bangladesh belarus brazil brunei
          cambodia chad croatia denmark eritrea france ghana iceland
          japan laos luxembourg malta micronesia mozambique nicaragua
          panama portugal sao-tome-and-principe singapore south-korea
          sri-lanka united-kingdom venezuela vietnam)
        actual = page.all('select option').map(&:value)
        assert_equal expected, actual
      end

      select "United Kingdom", from: "response"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus/1975-05-05/united-kingdom"

      within '.done-questions' do
        assert page.has_link?("Start again", href: '/country-and-date-sample')
        within 'tr.section:nth-child(1)' do
          within 'td.previous-question-title' do
            assert_page_has_content "Which country do you live in?"
          end
          within('td.previous-question-body') { assert_page_has_content "Belarus" }
          within('.link-right') { assert page.has_link?("Change", href: "/country-and-date-sample/y?previous_response=belarus") }
        end

        within 'tr.section:nth-child(2)' do
          within 'td.previous-question-title' do
            assert_page_has_content "What date did you move there?"
          end

          within('td.previous-question-body') { assert_page_has_content "5 May 1975" }
          within('.link-right') { assert page.has_link?("Change", href: "/country-and-date-sample/y/belarus?previous_response=1975-05-05") }
        end

        within 'tr.section:nth-child(3)' do
          within 'td.previous-question-title' do
            assert_page_has_content "Which country were you born in?"
          end

          within('.previous-question-body') { assert_page_has_content "United Kingdom" }
          within('.link-right') { assert page.has_link?("Change", href: "/country-and-date-sample/y/belarus/1975-05-05?previous_response=united-kingdom") }
        end
      end

      within '.outcome:nth-child(1)' do
        within '.result-info' do
          within('h2.result-title') { assert_page_has_content "Great - you've lived in belarus for 37 years, and were born in united-kingdom!" }
        end
      end
    end
  end # with_and_without_javascript

  should "return a 503 if the worldwide API errors" do
    stub_request(:get, %r{\A#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}}).to_timeout

    visit "/country-and-date-sample/y"
    assert_equal 503, page.status_code
  end

  should "handle country selects using the legacy data including and omitting the UK option" do
    visit "/country-legacy-sample/y"

    within '.current-question' do
      within 'h2' do
        assert_page_has_content "Which country do you live in?"
      end
    end
    within '.question-body' do
      assert page.has_select?("response")
      assert page.has_no_xpath? "//select/option[@value = 'united-kingdom']"
    end

    select "Belarus", from: "response"
    click_on "Next step"

    assert_current_url "/country-legacy-sample/y/belarus"

    within '.done-questions' do
      assert page.has_link?("Start again", href: '/country-legacy-sample')
      within 'tr.section:nth-child(1)' do
        within 'td.previous-question-title' do
          assert_page_has_content "Which country do you live in?"
        end
        within('td.previous-question-body') { assert_page_has_content "Belarus" }
        within('.link-right') { assert page.has_link?("Change", href: "/country-legacy-sample/y?previous_response=belarus") }
      end
    end

    within '.current-question' do
      within 'h2' do
        assert_page_has_content "Which country were you born in?"
        assert page.has_xpath? "//select/option[@value = 'united-kingdom']"
      end
    end

    within '.question-body' do
      assert page.has_select?("response")
    end

    select "United Kingdom", from: "response"
    click_on "Next step"

    assert_current_url "/country-legacy-sample/y/belarus/united-kingdom"

    within '.outcome:nth-child(1)' do
      within '.result-info' do
        within('h2.result-title') { assert_page_has_content "Great - you live in belarus and you were born in united-kingdom!" }
      end
    end
  end
end
