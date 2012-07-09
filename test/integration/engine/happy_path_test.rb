# encoding: UTF-8
require_relative '../../integration_test_helper'

class HappyPathTest < ActionDispatch::IntegrationTest
  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures flows})
    FLOW_REGISTRY_OPTIONS[:load_path] = fixture_flows_path
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:load_path)
  end

  %w(non_javascript javascript).each do |test_type|
    context "with javascript #{test_type == 'javascript' ? 'enabled' : 'disabled'}" do
      setup do
        if test_type == 'javascript'
          Capybara.current_driver = Capybara.javascript_driver
        end
      end
      should "happy path through a flow" do
        visit "/bridge-of-death"

        assert_current_url "/bridge-of-death"

        assert page.has_xpath?("//meta[@name = 'description'][@content = 'The Gorge of Eternal Peril!!!']")

        within 'h1' do
          assert_page_has_content("Quick answer")
          assert_page_has_content("The Bridge of Death")
        end
        within 'h2' do
          assert_page_has_content("Avoid the Gorge of Eternal Peril!!!")
        end
        within '.intro' do
          within('h2') { assert_page_has_content("STOP!") }
          assert_page_has_content("He who would cross the Bridge of Death Must answer me These questions three Ere the other side he see.")

          assert page.has_no_content?("-----") # markdown should be rendered, not output

          assert page.has_link?("Get started", :href => "/bridge-of-death/y")
        end

        click_on "Get started"

        assert_current_url "/bridge-of-death/y"

        within '.current-question' do
          within 'h2' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "What...is your name?"
          end
          within '.question-body' do
            assert page.has_field?("Name:", :type => :text)
          end
        end

        fill_in "Name:", :with => "Lancelot"
        click_on "Next step"

        assert_current_url "/bridge-of-death/y/Lancelot"

        within '.done-questions' do
          within('.start-again') { assert page.has_link?("Start again", :href => '/bridge-of-death') }
          within 'ol li.done' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "1" }
              assert_page_has_content "What...is your name?"
            end
            within('.answer') { assert_page_has_content "Lancelot" }
            # TODO: Fix wierd ?& in link...
            within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y?&previous_response=Lancelot") }
          end
        end

        within '.current-question' do
          within 'h2' do
            within('.question-number') { assert_page_has_content "2" }
            assert_page_has_content "What...is your quest?"
          end
          within '.question-body' do
            assert page.has_field?("To seek the Holy Grail", :type => 'radio', :value => "to_seek_the_holy_grail")
            assert page.has_field?("To rescue the princess", :type => 'radio', :value => "to_rescue_the_princess")
            assert page.has_field?("I dunno", :type => 'radio', :value => "dunno")
            # Assert they're in the correct order
            options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
            assert_equal ["To seek the Holy Grail", "To rescue the princess", "I dunno"], options
          end
        end

        choose "To seek the Holy Grail"
        click_on "Next step"

        assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail"

        within '.done-questions' do
          within('.start-again') { assert page.has_link?("Start again", :href => '/bridge-of-death') }
          within 'ol li.done:nth-child(1)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "1" }
              assert_page_has_content "What...is your name?"
            end
            within('.answer') { assert_page_has_content "Lancelot" }
            # TODO: Fix wierd ?& in link...
            within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y?&previous_response=Lancelot") }
          end
          within 'ol li.done:nth-child(2)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "2" }
              assert_page_has_content "What...is your quest?"
            end
            within('.answer') { assert_page_has_content "To seek the Holy Grail" }
            within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
          end
        end

        within '.current-question' do
          within 'h2' do
            within('.question-number') { assert_page_has_content "3" }
            assert_page_has_content "What...is your favorite colour?"
          end
          within '.question-body' do
            assert page.has_field?("Blue", :type => 'radio', :value => "blue")
            assert page.has_field?("Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", :type => 'radio', :value => "blue_no_yellow")
            assert page.has_field?("Red", :type => 'radio', :value => "red")
            # Assert they're in the correct order
            options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
            assert_equal ["Blue", "Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", "Red"], options
          end
        end

        choose "Blue"
        click_on "Next step"

        assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail/blue"

        within '.done-questions' do
          within('.start-again') { assert page.has_link?("Start again", :href => '/bridge-of-death') }
          within 'ol li.done:nth-child(1)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "1" }
              assert_page_has_content "What...is your name?"
            end
            within('.answer') { assert_page_has_content "Lancelot" }
            # TODO: Fix wierd ?& in link...
            within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y?&previous_response=Lancelot") }
          end
          within 'ol li.done:nth-child(2)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "2" }
              assert_page_has_content "What...is your quest?"
            end
            within('.answer') { assert_page_has_content "To seek the Holy Grail" }
            within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
          end
          within 'ol li.done:nth-child(3)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "3" }
              assert_page_has_content "What...is your favorite colour?"
            end
            within('.answer') { assert_page_has_content "Blue" }
            within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail?previous_response=blue") }
          end
        end

        within '.outcome' do
          within '.result-info' do
            within('h2.result-title') { assert_page_has_content "Right, off you go." }
            assert_page_has_content "Oh! Well, thank you. Thank you very much."
          end
        end
      end

      should "handle money and salary questions" do
        visit "/money-and-salary-sample/y"

        within '.current-question' do
          within 'h2' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "How much do you earn?"
          end
          within '.question-body' do
            assert page.has_field?("£", :type => :text)
            assert page.has_select?("per", :options => %w(week month))
          end
        end

        fill_in "£", :with => "5000"
        select "month", :from => "per"
        click_on "Next step"

        assert_current_url "/money-and-salary-sample/y/5000.0-month"

        within '.done-questions' do
          within('.start-again') { assert page.has_link?("Start again", :href => '/money-and-salary-sample') }
          within 'ol li.done' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "1" }
              assert_page_has_content "How much do you earn?"
            end
            within('.answer') { assert_page_has_content "£5,000 per month" }
            # TODO: Fix wierd ?& in link...
            within('.undo') { assert page.has_link?("Change this answer", :href => "/money-and-salary-sample/y?&previous_response=5000.0-month") }
          end
        end

        within '.current-question' do
          within 'h2' do
            within('.question-number') { assert_page_has_content "2" }
            assert_page_has_content "What size bonus do you want?"
          end
          within '.question-body' do
            assert page.has_field?("£", :type => :text)
          end
        end

        fill_in "£", :with => "1000000"
        click_on "Next step"

        assert_current_url "/money-and-salary-sample/y/5000.0-month/1000000.0"

        within '.done-questions' do
          within('.start-again') { assert page.has_link?("Start again", :href => '/money-and-salary-sample') }
          within 'ol li.done:nth-child(1)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "1" }
              assert_page_has_content "How much do you earn?"
            end
            within('.answer') { assert_page_has_content "£5,000 per month" }
            # TODO: Fix wierd ?& in link...
            within('.undo') { assert page.has_link?("Change this answer", :href => "/money-and-salary-sample/y?&previous_response=5000.0-month") }
          end
          within 'ol li.done:nth-child(2)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "2" }
              assert_page_has_content "What size bonus do you want?"
            end
            within('.answer') { assert_page_has_content "£1,000,000" }
            # TODO: Fix wierd ?& in link...
            within('.undo') { assert page.has_link?("Change this answer", :href => "/money-and-salary-sample/y/5000.0-month?previous_response=1000000.0") }
          end
        end

        within '.outcome' do
          within '.result-info' do
            within('h2.result-title') { assert_page_has_content "OK, here you go." }
            within('.info-notice') { assert_page_has_content "This is allowed because £1,000,000 is more than your annual salary of £60,000" }
          end
        end
      end

    should "handle country and date questions" do
      visit "/country-and-date-sample/y"

      within '.current-question' do
        within 'h2' do
          within('.question-number') { assert_page_has_content "1" }
          assert_page_has_content "Which country do you live in?"
        end
      end
      within '.question-body' do
        # TODO Check country list
        assert page.has_select?("response")
      end

      select "Belarus", :from => "response"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/country-and-date-sample') }
        within 'ol li.done:nth-child(1)' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "Which country do you live in?"
          end
          within('.answer') { assert_page_has_content "Belarus" }
          # TODO: Fix weird ?& in link
          within('.undo') { assert page.has_link?("Change this answer", :href => "/country-and-date-sample/y?&previous_response=belarus") }
        end
      end

      within '.current-question' do
        within 'h2' do
          within('.question-number') { assert_page_has_content "2" }
          assert_page_has_content "What date did you move there?"
        end
      end

      within '.question-body' do
        # TODO Check options for dates
        assert page.has_select? 'Day'
        assert page.has_select? 'Month'
        assert page.has_select? 'Year'
      end

      select "5", :from => "Day"
      select "May", :from => "Month"
      select "1975", :from => "Year"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus/1975-05-05"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/country-and-date-sample') }
          within 'ol li.done:nth-child(1)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "1" }
              assert_page_has_content "Which country do you live in?"
            end
            within('.answer') { assert_page_has_content "Belarus" }
            # TODO: Fix wierd ?& in link...
            within('.undo') { assert page.has_link?("Change this answer", :href => "/country-and-date-sample/y?&previous_response=belarus") }
          end
          within 'ol li.done:nth-child(2)' do
            within 'h3' do
              within('.question-number') { assert_page_has_content "2" }
              assert_page_has_content "What date did you move there?"
            end
            within('.answer') { assert_page_has_content "5 May 1975" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/country-and-date-sample/y/belarus?previous_response=1975-05-05") }
        end
      end

      within '.outcome' do
          within '.result-info' do
            within('h2.result-title') { assert_page_has_content "Great - you've lived in belarus for 37 years!" }
          end
        end
      end
    end
  end # each test type

  should "calculate alternate path correctly" do
    visit "/bridge-of-death/y"

    fill_in "Name:", :with => "Robin"
    click_on "Next step"

    choose "To seek the Holy Grail"
    click_on "Next step"

    assert_current_url "/bridge-of-death/y/Robin/to_seek_the_holy_grail"

    within '.done-questions' do
      within('.start-again') { assert page.has_link?("Start again", :href => '/bridge-of-death') }
      within 'ol li.done:nth-child(1)' do
        within 'h3' do
          within('.question-number') { assert_page_has_content "1" }
          assert_page_has_content "What...is your name?"
        end
        within('.answer') { assert_page_has_content "Robin" }
        # TODO: Fix wierd ?& in link...
        within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y?&previous_response=Robin") }
      end
      within 'ol li.done:nth-child(2)' do
        within 'h3' do
          within('.question-number') { assert_page_has_content "2" }
          assert_page_has_content "What...is your quest?"
        end
        within('.answer') { assert_page_has_content "To seek the Holy Grail" }
        within('.undo') { assert page.has_link?("Change this answer", :href => "/bridge-of-death/y/Robin?previous_response=to_seek_the_holy_grail") }
      end
    end

    within '.current-question' do
      within 'h2' do
        within('.question-number') { assert_page_has_content "3" }
        assert_page_has_content "What...is the capital of Assyria?"
      end
      within '.question-body' do
        assert page.has_field?("Answer:", :type => :text)
      end
    end

    fill_in "Answer:", :with => "I don't know THAT"
    click_on "Next step"

    within '.outcome' do
      within '.result-info' do
        within('h2.result-title') { assert_page_has_content "AAAAARRRRRRRRRRRRRRRRGGGGGHHH!!!!!!!" }
        within('.info-notice') { assert_page_has_content "Robin is thrown into the Gorge of Eternal Peril" }
      end
    end
  end
end
