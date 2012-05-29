require_relative "../integration_test_helper"
require_relative "smart_answer_test_helper"

class ReportALostOrStolenPassportTest < ActionDispatch::IntegrationTest
  include SmartAnswerTestHelper

  setup do
    visit "/report-a-lost-or-stolen-passport"
    click_on "Get started"
  end

  should "ask whether your passport has been lost or stolen" do
    expect_question "Has your passport been lost or stolen?"
  end

  context "Lost passport" do
    setup do
      respond_with "lost"
    end

    should "ask whether the passport is for a child or adult" do
      expect_question "Adult or child passport?"
    end

    context "for an Adult" do
      setup do
        respond_with "adult"
      end

      should "ask where your passport was lost" do
        expect_question "Where was your passport lost?"
      end

      context "in the UK" do
        setup do
          respond_with "in the UK"
        end

        should "tell you to fill out the LS01 form" do
          assert_results_contain "Complete a lost or stolen (LS01) notification form online."
        end
      end

      context "abroad" do
        setup do
          respond_with "abroad"
        end

        should "ask which country you lost your passport in" do
          expect_question "Which country?"
        end

        context "in Azerbaijan" do
          setup do
            respond_with "Azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_results_contain "Report the loss to the UK embassy, consulate or high commission of Azerbaijan."
          end
        end
      end
    end

    context "for a Child" do
      setup do
        respond_with "child"
      end

      should "ask where your passport was lost" do
        expect_question "Where was your passport lost?"
      end

      context "In UK" do
        setup do
          respond_with "in the UK"
        end

        should "tell you to fill out the LS01 form" do
          assert_results_contain "Complete a lost or stolen (LS01) notification form online."
        end
      end

      context "Abroad" do
        setup do
          respond_with "abroad"
        end

        should "ask which country you lost your passport in" do
          expect_question "Which country?"
        end

        context "in Azerbaijan" do
          setup do
            respond_with "Azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_results_contain "Report the loss to the UK embassy, consulate or high commission of Azerbaijan."
          end
        end
      end
    end
  end

  context "Passport Stolen" do
    setup do
      respond_with "stolen"
    end

    should "ask whether the passport is for a child or adult" do
      expect_question "Adult or child passport?"
    end

    context "for an Adult" do
      setup do
        respond_with "adult"
      end

      should "ask where your passport was stolen" do
        expect_question "Where was your passport stolen?"
      end

      context "in the UK" do
        setup do
          respond_with "in the UK"
        end

        should "tell you to report it to the police" do
          assert_results_contain "You must contact the police and report your passport as stolen."
        end
      end

      context "abroad" do
        setup do
          respond_with "abroad"
        end

        should "ask in which country your passport was stolen" do
          expect_question "Which country?"
        end

        context "in Azerbaijan" do
          setup do
            respond_with "Azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_results_contain "Report the loss to the UK embassy, consulate or high commission of Azerbaijan."
          end
        end
      end
    end

    context "for a Child" do
      setup do
        respond_with "child"
      end

      should "ask where your passport was stolen" do
        expect_question "Where was your passport stolen?"
      end

      context "in the UK" do
        setup do
          respond_with "in the UK"
        end

        should "tell you to report it to the police" do
          assert_results_contain "You must contact the police and report your passport as stolen."
        end
      end

      context "abroad" do
        setup do
          respond_with "abroad"
        end

        should "ask in which country your passport was stolen" do
          expect_question "Which country?"
        end

        context "in Azerbaijan" do
          setup do
            respond_with "Azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_results_contain "Report the loss to the UK embassy, consulate or high commission of Azerbaijan."
            assert page.has_css?("div.contact")
          end
        end
      end
    end
  end
end