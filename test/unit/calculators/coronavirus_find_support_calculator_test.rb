require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CoronavirusFindSupportCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CoronavirusFindSupportCalculator.new
    end

    context "#next_question" do
      context "user is on the need_help_with? node" do
        should "return feel_safe? when paying_bills has been chosen" do
          @calculator.need_help_with = "feeling_unsafe"
          assert_equal @calculator.next_question(:need_help_with?), :feel_safe?
        end

        should "return afford_rent_mortgage_bills? when paying_bills has been chosen" do
          @calculator.need_help_with = "paying_bills"
          assert_equal @calculator.next_question(:need_help_with?), :afford_rent_mortgage_bills?
        end

        should "return self_employed? when getting_food has been chosen" do
          @calculator.need_help_with = "getting_food"
          assert_equal @calculator.next_question(:need_help_with?), :afford_food?
        end

        should "return self_employed? when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:need_help_with?), :self_employed?
        end

        should "return worried_about_work? when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:need_help_with?), :worried_about_work?
        end

        should "return have_somewhere_to_live? when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:need_help_with?), :have_somewhere_to_live?
        end

        should "return mental_health_worries? when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:need_help_with?), :mental_health_worries?
        end

        should "return nation? when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:need_help_with?), :nation?
        end
      end

      context "user is on the feel_safe? node" do
        should "return afford_rent_mortgage_bills? when paying_bills has been chosen" do
          @calculator.need_help_with = "paying_bills"
          assert_equal @calculator.next_question(:feel_safe?), :afford_rent_mortgage_bills?
        end

        should "return self_employed? when getting_food has been chosen" do
          @calculator.need_help_with = "getting_food"
          assert_equal @calculator.next_question(:feel_safe?), :afford_food?
        end

        should "return self_employed? when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:feel_safe?), :self_employed?
        end

        should "return worried_about_work? when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:feel_safe?), :worried_about_work?
        end

        should "return have_somewhere_to_live? when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:feel_safe?), :have_somewhere_to_live?
        end

        should "return mental_health_worries? when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:feel_safe?), :mental_health_worries?
        end

        should "return nation? when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:feel_safe?), :nation?
        end
      end

      context "user is on the afford_rent_mortgage_bills? node" do
        should "return self_employed? when getting_food has been chosen" do
          @calculator.need_help_with = "getting_food"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills?), :afford_food?
        end

        should "return self_employed? when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills?), :self_employed?
        end

        should "return worried_about_work? when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills?), :worried_about_work?
        end

        should "return have_somewhere_to_live? when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills?), :have_somewhere_to_live?
        end

        should "return mental_health_worries? when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills?), :mental_health_worries?
        end

        should "return nation? when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills?), :nation?
        end
      end

      context "user is on the get_food? node" do
        should "return self_employed? when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:get_food?), :self_employed?
        end

        should "return worried_about_work? when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:get_food?), :worried_about_work?
        end

        should "return have_somewhere_to_live? when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:get_food?), :have_somewhere_to_live?
        end

        should "return mental_health_worries? when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:get_food?), :mental_health_worries?
        end

        should "return nation? when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:get_food?), :nation?
        end
      end

      context "user is on the have_you_been_made_unemployed? node" do
        should "return worried_about_work? when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:have_you_been_made_unemployed?), :worried_about_work?
        end

        should "return have_somewhere_to_live? when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:have_you_been_made_unemployed?), :have_somewhere_to_live?
        end

        should "return mental_health_worries? when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:have_you_been_made_unemployed?), :mental_health_worries?
        end

        should "return nation? when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:have_you_been_made_unemployed?), :nation?
        end
      end

      context "user is on the are_you_off_work_ill? node" do
        should "return have_somewhere_to_live? when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:are_you_off_work_ill?), :have_somewhere_to_live?
        end

        should "return mental_health_worries? when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:are_you_off_work_ill?), :mental_health_worries?
        end

        should "return nation? when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:are_you_off_work_ill?), :nation?
        end
      end

      context "user is on the have_you_been_evicted? node" do
        should "return mental_health_worries? when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:have_you_been_evicted?), :mental_health_worries?
        end

        should "return nation? when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:have_you_been_evicted?), :nation?
        end
      end
    end

    context "#needs_help_with?" do
      should "return true if the given help item has been chosen" do
        @calculator.need_help_with = "one,two,three,four"
        assert_equal @calculator.needs_help_with?("one"), true
      end

      should "return false if the given help item has not been chosen" do
        @calculator.need_help_with = "one,two,three,four"
        assert_equal @calculator.needs_help_with?("five"), false
      end

      should "return false if need_help_with is an empty string" do
        @calculator.need_help_with = ""
        assert_equal @calculator.needs_help_with?("one"), false
      end

      should "return false if need_help_with is nil" do
        @calculator.need_help_with = nil
        assert_equal @calculator.needs_help_with?("one"), false
      end
    end

    context "#has_results?" do
      should "return true if at least one help item has been chosen" do
        @calculator.need_help_with = "one"
        assert_equal @calculator.has_results?, true
      end

      should "return false if need_help_with is an empty string" do
        @calculator.need_help_with = ""
        assert_equal @calculator.has_results?, false
      end

      should "return false if need_help_with is nil" do
        @calculator.need_help_with = nil
        assert_equal @calculator.has_results?, false
      end
    end

    context "#needs_help_in?" do
      should "return true if the given nation has been chosen" do
        @calculator.nation = "one"
        assert_equal @calculator.needs_help_in?("one"), true
      end

      should "return false if the given nation has not been chosen" do
        @calculator.nation = "one"
        assert_equal @calculator.needs_help_in?("five"), false
      end

      should "return false if nation is an empty string" do
        @calculator.nation = ""
        assert_equal @calculator.needs_help_in?("one"), false
      end

      should "return false if nation is nil" do
        @calculator.nation = nil
        assert_equal @calculator.needs_help_in?("one"), false
      end
    end

    context "#user_feels_unsafe?" do
      context "user has selected feeling_unsafe" do
        setup do
          @calculator.need_help_with = "feeling_unsafe"
        end

        should "return false if the user feels safe" do
          @calculator.feel_safe = "yes"
          assert_equal @calculator.user_feels_unsafe?, false
        end

        should "return true if the user feels safe but not completely" do
          @calculator.feel_safe = "yes_but"
          assert_equal @calculator.user_feels_unsafe?, true
        end

        should "return true if the user does not feel safe" do
          @calculator.feel_safe = "no"
          assert_equal @calculator.user_feels_unsafe?, true
        end

        should "return true if the user is unsure about feeling safe" do
          @calculator.feel_safe = "not_sure"
          assert_equal @calculator.user_feels_unsafe?, true
        end
      end

      context "user has not selected feeling_unsafe" do
        should "return false" do
          @calculator.need_help_with = ""
          @calculator.feel_safe = "no"
          assert_equal @calculator.user_feels_unsafe?, false
        end
      end
    end

    context "#user_cannot_pay_their_bills?" do
      context "user has selected paying_bills" do
        setup do
          @calculator.need_help_with = "paying_bills"
        end

        should "return true if the user is finding it hard to pay their bills" do
          @calculator.afford_rent_mortgage_bills = "yes"
          assert_equal @calculator.user_cannot_pay_their_bills?, true
        end

        should "return false if the user is not finding it hard to pay their bills" do
          @calculator.afford_rent_mortgage_bills = "no"
          assert_equal @calculator.user_cannot_pay_their_bills?, false
        end

        should "return true if the user is unsure if they are finding it hard to pay their bills" do
          @calculator.afford_rent_mortgage_bills = "not_sure"
          assert_equal @calculator.user_cannot_pay_their_bills?, true
        end
      end

      context "user has not selected paying_bills" do
        should "return false" do
          @calculator.need_help_with = ""
          @calculator.afford_rent_mortgage_bills = "yes"
          assert_equal @calculator.user_cannot_pay_their_bills?, false
        end
      end
    end

    context "#user_cannot_get_food?" do
      context "user has selected getting_food" do
        setup do
          @calculator.need_help_with = "getting_food"
        end

        context "user is finding it hard to afford food" do
          setup do
            @calculator.afford_food = "yes"
          end

          should "return false if the user can get food" do
            @calculator.get_food = "yes"
            assert_equal @calculator.user_cannot_get_food?, false
          end

          should "return true if the user cannot get food" do
            @calculator.get_food = "no"
            assert_equal @calculator.user_cannot_get_food?, true
          end

          should "return true if the user is unsure if they can get food" do
            @calculator.get_food = "not_sure"
            assert_equal @calculator.user_cannot_get_food?, true
          end
        end

        context "user is unsure if they are finding it hard afford food" do
          setup do
            @calculator.afford_food = "not_sure"
          end

          should "return false if the user can get food" do
            @calculator.get_food = "yes"
            assert_equal @calculator.user_cannot_get_food?, false
          end

          should "return true if the user cannot get food" do
            @calculator.get_food = "no"
            assert_equal @calculator.user_cannot_get_food?, true
          end

          should "return true if the user is unsure if they can get food" do
            @calculator.get_food = "not_sure"
            assert_equal @calculator.user_cannot_get_food?, true
          end
        end

        context "user is not finding it hard to afford food" do
          setup do
            @calculator.afford_food = "no"
          end

          should "return false if the user can get food" do
            @calculator.get_food = "yes"
            assert_equal @calculator.user_cannot_get_food?, false
          end

          should "return false if the user cannot get food" do
            @calculator.get_food = "no"
            assert_equal @calculator.user_cannot_get_food?, false
          end

          should "return false if the user is unsure if they can get food" do
            @calculator.get_food = "not_sure"
            assert_equal @calculator.user_cannot_get_food?, false
          end
        end
      end

      context "user has not selected getting_food" do
        should "return false" do
          @calculator.need_help_with = ""
          @calculator.afford_food = "yes"
          @calculator.get_food = "no"
          assert_equal @calculator.user_cannot_get_food?, false
        end
      end
    end

    context "#user_is_worried_about_going_to_work?" do
      context "user has selected going_to_work" do
        setup do
          @calculator.need_help_with = "going_to_work"
        end

        should "return true if the user is worried about work" do
          @calculator.worried_about_work = "yes"
          assert_equal @calculator.user_is_worried_about_going_to_work?, true
        end

        should "return false if the user is not worried about work" do
          @calculator.worried_about_work = "no"
          assert_equal @calculator.user_is_worried_about_going_to_work?, false
        end

        should "return true if the user is unsure about being worried about work" do
          @calculator.worried_about_work = "not_sure"
          assert_equal @calculator.user_is_worried_about_going_to_work?, true
        end
      end

      context "user has not selected going_to_work" do
        should "return false" do
          @calculator.need_help_with = ""
          @calculator.worried_about_work = "yes"
          assert_equal @calculator.user_is_worried_about_going_to_work?, false
        end
      end
    end

    context "#user_is_unemployed?" do
      context "user has selected being_unemployed" do
        setup do
          @calculator.need_help_with = "being_unemployed"
        end

        context "user is not ill" do
          setup do
            @calculator.are_you_off_work_ill = "no"
          end

          context "user is not self-employed" do
            setup do
              @calculator.self_employed = "no"
            end

            should "return true if the user has been made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_1"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user is going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_2"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user is unsure if they are going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "not_sure"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return false if the user has not been made unemployed" do
              @calculator.have_you_been_made_unemployed = "no"
              assert_equal @calculator.user_is_unemployed?, false
            end
          end

          context "user is self-employed" do
            setup do
              @calculator.self_employed = "yes"
            end

            should "return false if the user has been made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_1"
              assert_equal @calculator.user_is_unemployed?, false
            end

            should "return false if the user is going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_2"
              assert_equal @calculator.user_is_unemployed?, false
            end

            should "return false if the user is unsure if they are going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "not_sure"
              assert_equal @calculator.user_is_unemployed?, false
            end

            should "return false if the user has not been made unemployed" do
              @calculator.have_you_been_made_unemployed = "no"
              assert_equal @calculator.user_is_unemployed?, false
            end
          end
        end

        context "user is ill" do
          setup do
            @calculator.are_you_off_work_ill = "yes"
          end

          context "user is not self-employed" do
            setup do
              @calculator.self_employed = "no"
            end

            should "return true if the user has been made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_1"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user is going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_2"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user is unsure if they are going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "not_sure"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user has not been made unemployed" do
              @calculator.have_you_been_made_unemployed = "no"
              assert_equal @calculator.user_is_unemployed?, true
            end
          end

          context "user is self-employed" do
            setup do
              @calculator.self_employed = "yes"
            end

            should "return true if the user has been made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_1"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user is going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "yes_2"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user is unsure if they are going to be made unemployed" do
              @calculator.have_you_been_made_unemployed = "not_sure"
              assert_equal @calculator.user_is_unemployed?, true
            end

            should "return true if the user has not been made unemployed" do
              @calculator.have_you_been_made_unemployed = "no"
              assert_equal @calculator.user_is_unemployed?, true
            end
          end
        end
      end

      context "user has not selected being_unemployed" do
        should "return false" do
          @calculator.need_help_with = ""
          @calculator.are_you_off_work_ill = "yes"
          @calculator.self_employed = "no"
          @calculator.have_you_been_made_unemployed = "yes"
          assert_equal @calculator.user_is_unemployed?, false
        end
      end
    end

    context "#user_needs_somewhere_to_live?" do
      context "user has selected somewhere_to_live" do
        setup do
          @calculator.need_help_with = "somewhere_to_live"
        end

        context "user does have somewhere to live" do
          setup do
            @calculator.have_somewhere_to_live = "yes"
          end

          should "return true if the user has been evicted" do
            @calculator.have_you_been_evicted = "yes"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user going to be evicted" do
            @calculator.have_you_been_evicted = "soon"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return false if the user is not going to be evicted" do
            @calculator.have_you_been_evicted = "no"
            assert_equal @calculator.user_needs_somewhere_to_live?, false
          end

          should "return true if the user is unsure if they are going to be evicted" do
            @calculator.have_you_been_evicted = "not_sure"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end
        end

        context "user may not have somewhere to live" do
          setup do
            @calculator.have_somewhere_to_live = "yes_but"
          end

          should "return true if the user has been evicted" do
            @calculator.have_you_been_evicted = "yes"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user going to be evicted" do
            @calculator.have_you_been_evicted = "soon"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user is not going to be evicted" do
            @calculator.have_you_been_evicted = "no"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user is unsure if they are going to be evicted" do
            @calculator.have_you_been_evicted = "not_sure"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end
        end

        context "user does not have somewhere to live" do
          setup do
            @calculator.have_somewhere_to_live = "no"
          end

          should "return true if the user has been evicted" do
            @calculator.have_you_been_evicted = "yes"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user going to be evicted" do
            @calculator.have_you_been_evicted = "soon"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user is not going to be evicted" do
            @calculator.have_you_been_evicted = "no"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user is unsure if they are going to be evicted" do
            @calculator.have_you_been_evicted = "not_sure"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end
        end

        context "user unsure if they have somewhere to live" do
          setup do
            @calculator.have_somewhere_to_live = "not_sure"
          end

          should "return true if the user has been evicted" do
            @calculator.have_you_been_evicted = "yes"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user going to be evicted" do
            @calculator.have_you_been_evicted = "soon"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user is not going to be evicted" do
            @calculator.have_you_been_evicted = "no"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end

          should "return true if the user is unsure if they are going to be evicted" do
            @calculator.have_you_been_evicted = "not_sure"
            assert_equal @calculator.user_needs_somewhere_to_live?, true
          end
        end
      end

      context "user has not selected somewhere_to_live" do
        should "return false" do
          @calculator.need_help_with = ""
          @calculator.have_somewhere_to_live = "no"
          @calculator.have_you_been_evicted = "yes"
          assert_equal @calculator.user_needs_somewhere_to_live?, false
        end
      end
    end

    context "#user_has_mental_health_worries?" do
      context "user has selected mental_health" do
        setup do
          @calculator.need_help_with = "mental_health"
        end

        should "return true if the user has mental health worries" do
          @calculator.mental_health_worries = "yes"
          assert_equal @calculator.user_has_mental_health_worries?, true
        end

        should "return true if the user is unsure if they have mental health worries" do
          @calculator.mental_health_worries = "not_sure"
          assert_equal @calculator.user_has_mental_health_worries?, true
        end

        should "return false if the user does not have any mental health worries" do
          @calculator.mental_health_worries = "no"
          assert_equal @calculator.user_has_mental_health_worries?, false
        end
      end

      context "user has not selected mental_health" do
        should "return false" do
          @calculator.need_help_with = ""
          @calculator.mental_health_worries = "yes"
          assert_equal @calculator.user_has_mental_health_worries?, false
        end
      end
    end
  end
end
