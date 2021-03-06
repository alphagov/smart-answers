require_relative "../../test_helper"

module SmartAnswer::Calculators
  class FindCoronavirusSupportCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = FindCoronavirusSupportCalculator.new
    end

    context "#show_group?" do
      context "feel_unsafe" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_unsafe = "yes"

          assert @calculator.show_group?(:feeling_unsafe)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_unsafe = "no"

          assert_not @calculator.show_group?(:feeling_unsafe)
        end
      end

      context "paying_bills" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "paying_bills"
          @calculator.afford_rent_mortgage_bills = "yes"

          assert @calculator.show_group?(:paying_bills)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "paying_bills"
          @calculator.afford_rent_mortgage_bills = "no"

          assert_not @calculator.show_group?(:paying_bills)
        end
      end

      context "getting_food" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "getting_food"
          @calculator.afford_food = "yes"
          @calculator.get_food = "no"

          assert @calculator.show_group?(:getting_food)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "getting_food"
          @calculator.afford_food = "no"
          @calculator.get_food = "yes"

          assert_not @calculator.show_group?(:getting_food)
        end
      end

      context "being_unemployed" do
        should "return true when need help with being unemployed and unemployed" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "yes"

          assert @calculator.show_group?(:being_unemployed)
        end

        should "return true when need help with being unemployed and self-employed" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.self_employed = "yes"

          assert @calculator.show_group?(:being_unemployed)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "no"
          @calculator.self_employed = "no"

          assert_not @calculator.show_group?(:being_unemployed)
        end
      end

      context "self_isolating" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "self_isolating"
          @calculator.worried_about_self_isolating = "yes"

          assert @calculator.show_group?(:self_isolating)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "self_isolating"
          @calculator.worried_about_self_isolating = "no"

          assert_not @calculator.show_group?(:self_isolating)
        end
      end

      context "somewhere_to_live" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "no"
          @calculator.have_you_been_evicted = "yes"

          assert @calculator.show_group?(:somewhere_to_live)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "yes"
          @calculator.have_you_been_evicted = "no"

          assert_not @calculator.show_group?(:somewhere_to_live)
        end
      end

      context "mental_health" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "mental_health"
          @calculator.mental_health_worries = "yes"

          assert @calculator.show_group?(:mental_health)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "mental_health"
          @calculator.mental_health_worries = "no"

          assert_not @calculator.show_group?(:mental_health)
        end
      end
    end

    context "#show_section?" do
      context "feel_unsafe" do
        should "return true when not feeling safe" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_unsafe = "yes"

          assert @calculator.show_section?(:feel_unsafe)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_unsafe = "not_sure"

          assert @calculator.show_section?(:feel_unsafe)
        end

        should "return true when worried someone else" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_unsafe = "concerned_about_others"

          assert @calculator.show_section?(:feel_unsafe)
        end

        should "return false when feeling safe" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_unsafe = "no"

          assert_not @calculator.show_section?(:feel_unsafe)
        end
      end

      context "afford_rent_mortgage_bills" do
        should "return true when finding it hard to afford bills" do
          @calculator.need_help_with = "paying_bills"
          @calculator.afford_rent_mortgage_bills = "yes"

          assert @calculator.show_section?(:afford_rent_mortgage_bills)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "paying_bills"
          @calculator.afford_rent_mortgage_bills = "not_sure"

          assert @calculator.show_section?(:afford_rent_mortgage_bills)
        end

        should "return false when not finding it hard to afford bills" do
          @calculator.need_help_with = "paying_bills"
          @calculator.afford_rent_mortgage_bills = "no"

          assert_not @calculator.show_section?(:afford_rent_mortgage_bills)
        end
      end

      context "afford_food" do
        should "return true when can't affort food" do
          @calculator.need_help_with = "getting_food"
          @calculator.afford_food = "yes"

          assert @calculator.show_section?(:afford_food)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "getting_food"
          @calculator.afford_food = "not_sure"

          assert @calculator.show_section?(:afford_food)
        end

        should "return false when can afford food" do
          @calculator.need_help_with = "getting_food"
          @calculator.afford_food = "no"

          assert_not @calculator.show_section?(:afford_food)
        end
      end

      context "get_food" do
        should "return true when not able to get food" do
          @calculator.need_help_with = "getting_food"
          @calculator.get_food = "no"

          assert @calculator.show_section?(:get_food)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "getting_food"
          @calculator.get_food = "not_sure"

          assert @calculator.show_section?(:get_food)
        end
        should "return false when able to get food" do
          @calculator.need_help_with = "getting_food"
          @calculator.get_food = "yes"

          assert_not @calculator.show_section?(:get_food)
        end
      end

      context "self_employed" do
        should "return true when self employeed" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.self_employed = "yes"

          assert @calculator.show_section?(:self_employed)
        end

        should "return true when not sure if self employeed" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.self_employed = "not_sure"

          assert @calculator.show_section?(:self_employed)
        end

        should "return false when not self employed" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.self_employed = "no"

          assert_not @calculator.show_section?(:self_employed)
        end
      end

      context "have_you_been_made_unemployed" do
        should "return true when been made unemployed" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "yes_i_have_been_made_unemployed"

          assert @calculator.show_section?(:have_you_been_made_unemployed)
        end

        should "return true when been put on furlough" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "yes_i_have_been_put_on_furlough"

          assert @calculator.show_section?(:have_you_been_made_unemployed)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "not_sure"

          assert @calculator.show_section?(:have_you_been_made_unemployed)
        end

        should "return false when user when not unemployed" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "no"

          assert_not @calculator.show_section?(:have_you_been_made_unemployed)
        end

        should "return false when user hasn't answered" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = nil

          assert_not @calculator.show_section?(:have_you_been_made_unemployed)
        end
      end

      context "worried_about_work" do
        should "return true when worried about going into work" do
          @calculator.need_help_with = "going_to_work"
          @calculator.worried_about_work = "yes"

          assert @calculator.show_section?(:worried_about_work)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "going_to_work"
          @calculator.worried_about_work = "not_sure"

          assert @calculator.show_section?(:worried_about_work)
        end

        should "return false when not worried" do
          @calculator.need_help_with = "going_to_work"
          @calculator.worried_about_work = "no"

          assert_not @calculator.show_section?(:worried_about_work)
        end
      end

      context "worried_about_self_isolating" do
        should "return true when worried about self-isolating" do
          @calculator.need_help_with = "self_isolating"
          @calculator.worried_about_self_isolating = "yes"

          assert @calculator.show_section?(:worried_about_self_isolating)
        end

        should "return false when not worried about self-isolating" do
          @calculator.need_help_with = "self_isolating"
          @calculator.worried_about_self_isolating = "no"

          assert_not @calculator.show_section?(:worried_about_self_isolating)
        end
      end

      context "have_somewhere_to_live" do
        should "return true when nowhere to live" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "no"

          assert @calculator.show_section?(:have_somewhere_to_live)
        end

        should "return true when might lose somewhere to live" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "yes_but_i_might_lose_it"

          assert @calculator.show_section?(:have_somewhere_to_live)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "not_sure"

          assert @calculator.show_section?(:have_somewhere_to_live)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "yes"

          assert_not @calculator.show_section?(:have_somewhere_to_live)
        end
      end

      context "have_you_been_evicted" do
        should "return true when have been evicted" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_you_been_evicted = "yes"

          assert @calculator.show_section?(:have_you_been_evicted)
        end

        should "return true when have been soon to be evicted" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_you_been_evicted = "yes_i_might_be_soon"

          assert @calculator.show_section?(:have_you_been_evicted)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_you_been_evicted = "not_sure"

          assert @calculator.show_section?(:have_you_been_evicted)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_you_been_evicted = "no"

          assert_not @calculator.show_section?(:have_you_been_evicted)
        end
      end

      context "mental_health_worries" do
        should "return true when has worries" do
          @calculator.need_help_with = "mental_health"
          @calculator.mental_health_worries = "yes"

          assert @calculator.show_section?(:mental_health_worries)
        end

        should "return true when not sure" do
          @calculator.need_help_with = "mental_health"
          @calculator.mental_health_worries = "not_sure"

          assert @calculator.show_section?(:mental_health_worries)
        end

        should "return false when no worries" do
          @calculator.need_help_with = "mental_health"
          @calculator.mental_health_worries = "no"

          assert_not @calculator.show_section?(:mental_health_worries)
        end
      end
    end

    context "#has_results?" do
      should "return true when criteria is met" do
        @calculator.need_help_with = "feeling_unsafe,paying_bills,mental_health"
        @calculator.feel_unsafe = "yes"
        @calculator.afford_rent_mortgage_bills = "yes"
        @calculator.mental_health_worries = "no"

        assert_equal @calculator.has_results?, true
      end

      should "return false when criteria is not met" do
        @calculator.need_help_with = "feeling_unsafe,going_to_work,mental_health"
        @calculator.feel_unsafe = "no"
        @calculator.worried_about_work = "no"
        @calculator.mental_health_worries = "no"

        assert_equal @calculator.has_results?, false
      end

      should "return false the user does not need_help_with aything" do
        @calculator.need_help_with = ""
        assert_equal @calculator.has_results?, false

        @calculator.need_help_with = nil
        assert_equal @calculator.has_results?, false
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

      should "return true if the none item has been chosen" do
        @calculator.need_help_with = "none"
        assert_equal @calculator.needs_help_with?("one"), false
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

    context "#next_question" do
      context "user is on the need_help_with node" do
        should "return nation when 'none' has been chosen" do
          @calculator.need_help_with = "none"
          assert_equal @calculator.next_question(:need_help_with), :nation
        end

        should "return feel_unsafe when feeling unsafe has been chosen" do
          @calculator.need_help_with = "feeling_unsafe"
          assert_equal @calculator.next_question(:need_help_with), :feel_unsafe
        end

        should "return afford_rent_mortgage_bills when paying_bills has been chosen" do
          @calculator.need_help_with = "paying_bills"
          assert_equal @calculator.next_question(:need_help_with), :afford_rent_mortgage_bills
        end

        should "return self_employed when getting_food has been chosen" do
          @calculator.need_help_with = "getting_food"
          assert_equal @calculator.next_question(:need_help_with), :afford_food
        end

        should "return self_employed when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:need_help_with), :self_employed
        end

        should "return worried_about_work when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:need_help_with), :worried_about_work
        end

        should "return worried_about_self_isolating when self_isolating has been chosen" do
          @calculator.need_help_with = "self_isolating"
          assert_equal @calculator.next_question(:need_help_with), :worried_about_self_isolating
        end

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:need_help_with), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:need_help_with), :mental_health_worries
        end
      end

      context "user is on the feel_unsafe node" do
        should "return afford_rent_mortgage_bills when paying_bills has been chosen" do
          @calculator.need_help_with = "paying_bills"
          assert_equal @calculator.next_question(:feel_unsafe), :afford_rent_mortgage_bills
        end

        should "return self_employed when getting_food has been chosen" do
          @calculator.need_help_with = "getting_food"
          assert_equal @calculator.next_question(:feel_unsafe), :afford_food
        end

        should "return self_employed when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:feel_unsafe), :self_employed
        end

        should "return worried_about_work when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:feel_unsafe), :worried_about_work
        end

        should "return worried_about_self_isolating when self_isolating has been chosen" do
          @calculator.need_help_with = "self_isolating"
          assert_equal @calculator.next_question(:feel_unsafe), :worried_about_self_isolating
        end

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:feel_unsafe), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:feel_unsafe), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:feel_unsafe), :nation
        end
      end

      context "user is on the afford_rent_mortgage_bills node" do
        should "return self_employed when getting_food has been chosen" do
          @calculator.need_help_with = "getting_food"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills), :afford_food
        end

        should "return self_employed when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills), :self_employed
        end

        should "return worried_about_work when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills), :worried_about_work
        end

        should "return worried_about_self_isolating when self_isolating has been chosen" do
          @calculator.need_help_with = "self_isolating"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills), :worried_about_self_isolating
        end

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:afford_rent_mortgage_bills), :nation
        end
      end

      context "user is on the get_food node" do
        should "return self_employed when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:get_food), :self_employed
        end

        should "return worried_about_work when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:get_food), :worried_about_work
        end

        should "return worried_about_self_isolating when self_isolating has been chosen" do
          @calculator.need_help_with = "self_isolating"
          assert_equal @calculator.next_question(:get_food), :worried_about_self_isolating
        end

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:get_food), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:get_food), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:get_food), :nation
        end
      end

      context "user is on the have_you_been_made_unemployed node" do
        should "return worried_about_work when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:have_you_been_made_unemployed), :worried_about_work
        end

        should "return worried_about_self_isolating when self_isolating has been chosen" do
          @calculator.need_help_with = "self_isolating"
          assert_equal @calculator.next_question(:have_you_been_made_unemployed), :worried_about_self_isolating
        end

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:have_you_been_made_unemployed), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:have_you_been_made_unemployed), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:have_you_been_made_unemployed), :nation
        end
      end

      context "user is on the worried_about_work node" do
        should "return worried_about_self_isolating when self_isolating has been chosen" do
          @calculator.need_help_with = "self_isolating"
          assert_equal @calculator.next_question(:worried_about_work), :worried_about_self_isolating
        end

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:worried_about_work), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:worried_about_work), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:worried_about_work), :nation
        end
      end

      context "user is on the worried_about_self_isolating node" do
        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:worried_about_self_isolating), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:worried_about_self_isolating), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:worried_about_self_isolating), :nation
        end
      end

      context "user is on the have_you_been_evicted node" do
        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:have_you_been_evicted), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:have_you_been_evicted), :nation
        end
      end
    end
  end
end
