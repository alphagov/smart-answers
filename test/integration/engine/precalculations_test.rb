require_relative 'engine_test_helper'

class PrecalculationsTest < EngineIntegrationTest
  with_and_without_javascript do
    should "handle precalculations" do
      visit "/precalculation-sample"

      assert_current_url "/precalculation-sample"

      within '.intro' do
        assert page.has_link?("Start now", href: "/precalculation-sample/y")
      end

      click_on "Start now"

      assert_current_url "/precalculation-sample/y"

      # This is asserting that the form URL doesn't get created with a trailing /
      # If this happens, the cache servers strip off the / and redirect.  This breaks things.
      form = page.find(:xpath, "id('js-replaceable')//form")
      assert_equal "/precalculation-sample/y", form[:action]

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "How much wood would a woodchuck chuck if a woodchuck could chuck wood?"
        end
        within '.question-body' do
          assert page.has_field?("Amount:", type: "text")
        end
      end

      fill_in "Amount:", with: "10"
      click_on "Next step"

      assert_current_url "/precalculation-sample/y/10"

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "How many woodchucks do you have?"
        end
        within '.question-body' do
          assert page.has_field?("Amount:", type: "text")
        end
      end

      fill_in "Amount:", with: "42"
      click_on "Next step"

      assert_current_url "/precalculation-sample/y/10/42"

      within '.outcome:nth-child(1)' do
        within '.result-info' do
          within('h2.result-title') { assert_page_has_content "420 pieces of wood would be chucked." }
          within('.info-notice') { assert_page_has_content "42 woodchucks, each chucking 10 pieces of wood = 420 pieces of wood being chucked." }
        end
      end
    end
  end # with_and_without_javascript
end
