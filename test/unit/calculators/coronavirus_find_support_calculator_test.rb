require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CoronavirusFindSupportCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CoronavirusFindSupportCalculator.new
    end

    context "#show_group?" do
      context "feel_safe" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_safe = "no"

          assert @calculator.show_group?(:feeling_unsafe)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_safe = "yes"

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
        should "return true when criteria is met" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "yes"
          @calculator.self_employed = "no"

          assert @calculator.show_group?(:being_unemployed)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "no"
          @calculator.self_employed = "yes"

          assert_not @calculator.show_group?(:being_unemployed)
        end
      end

      context "going_in_to_work" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "going_in_to_work"
          @calculator.worried_about_work = "yes"
          @calculator.are_you_off_work_ill = "yes"

          assert @calculator.show_group?(:going_in_to_work)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "going_in_to_work"
          @calculator.worried_about_work = "no"
          @calculator.are_you_off_work_ill = "no"

          assert_not @calculator.show_group?(:going_in_to_work)
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
      context "feel_safe" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_safe = "no"

          assert @calculator.show_section?(:feel_safe)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "feeling_unsafe"
          @calculator.feel_safe = "yes"

          assert_not @calculator.show_section?(:feel_safe)
        end
      end

      context "afford_rent_mortgage_bills" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "paying_bills"
          @calculator.afford_rent_mortgage_bills = "yes"

          assert @calculator.show_section?(:afford_rent_mortgage_bills)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "paying_bills"
          @calculator.afford_rent_mortgage_bills = "no"

          assert_not @calculator.show_section?(:afford_rent_mortgage_bills)
        end
      end

      context "afford_food" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "getting_food"
          @calculator.afford_food = "yes"

          assert @calculator.show_section?(:afford_food)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "getting_food"
          @calculator.afford_food = "no"

          assert_not @calculator.show_section?(:afford_food)
        end
      end

      context "get_food" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "getting_food"
          @calculator.get_food = "no"

          assert @calculator.show_section?(:get_food)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "getting_food"
          @calculator.get_food = "yes"

          assert_not @calculator.show_section?(:get_food)
        end
      end

      context "have_you_been_made_unemployed" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "yes"

          assert @calculator.show_section?(:have_you_been_made_unemployed)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.have_you_been_made_unemployed = "no"

          assert_not @calculator.show_section?(:have_you_been_made_unemployed)
        end
      end

      context "self_employed" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.self_employed = "no"

          assert @calculator.show_section?(:self_employed)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "being_unemployed"
          @calculator.self_employed = "yes"

          assert_not @calculator.show_section?(:self_employed)
        end
      end

      context "worried_about_work" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "going_in_to_work"
          @calculator.worried_about_work = "yes"

          assert @calculator.show_section?(:worried_about_work)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "going_in_to_work"
          @calculator.worried_about_work = "no"

          assert_not @calculator.show_section?(:worried_about_work)
        end
      end

      context "are_you_off_work_ill" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "going_in_to_work"
          @calculator.are_you_off_work_ill = "yes"

          assert @calculator.show_section?(:are_you_off_work_ill)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "going_in_to_work"
          @calculator.are_you_off_work_ill = "no"

          assert_not @calculator.show_section?(:are_you_off_work_ill)
        end
      end

      context "have_somewhere_to_live" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "no"

          assert @calculator.show_section?(:have_somewhere_to_live)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_somewhere_to_live = "yes"

          assert_not @calculator.show_section?(:have_somewhere_to_live)
        end
      end

      context "have_you_been_evicted" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_you_been_evicted = "yes"

          assert @calculator.show_section?(:have_you_been_evicted)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "somewhere_to_live"
          @calculator.have_you_been_evicted = "no"

          assert_not @calculator.show_section?(:have_you_been_evicted)
        end
      end

      context "mental_health_worries" do
        should "return true when criteria is met" do
          @calculator.need_help_with = "mental_health"
          @calculator.mental_health_worries = "yes"

          assert @calculator.show_section?(:mental_health_worries)
        end

        should "return false when criteria is not met" do
          @calculator.need_help_with = "mental_health"
          @calculator.mental_health_worries = "no"

          assert_not @calculator.show_section?(:mental_health_worries)
        end
      end
    end

    context "#has_results?" do
      should "return true when criteria is met" do
        @calculator.need_help_with = "feeling_unsafe,paying_bills,mental_health"
        @calculator.feel_safe = "no"
        @calculator.afford_rent_mortgage_bills = "yes"
        @calculator.mental_health_worries = "no"

        assert_equal @calculator.has_results?, true
      end

      should "return false when criteria is not met" do
        @calculator.need_help_with = "feeling_unsafe,going_to_work,mental_health"
        @calculator.feel_safe = "yes"
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
        assert_equal @calculator.needs_help_with?("one"), true
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
        should "return feel_safe when 'none' has been chosen" do
          @calculator.need_help_with = "none"
          assert_equal @calculator.next_question(:need_help_with), :feel_safe
        end

        should "return feel_safe when paying_bills has been chosen" do
          @calculator.need_help_with = "feeling_unsafe"
          assert_equal @calculator.next_question(:need_help_with), :feel_safe
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

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:need_help_with), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:need_help_with), :mental_health_worries
        end
      end

      context "user is on the feel_safe node" do
        should "return afford_rent_mortgage_bills when paying_bills has been chosen" do
          @calculator.need_help_with = "paying_bills"
          assert_equal @calculator.next_question(:feel_safe), :afford_rent_mortgage_bills
        end

        should "return self_employed when getting_food has been chosen" do
          @calculator.need_help_with = "getting_food"
          assert_equal @calculator.next_question(:feel_safe), :afford_food
        end

        should "return self_employed when being_unemployed has been chosen" do
          @calculator.need_help_with = "being_unemployed"
          assert_equal @calculator.next_question(:feel_safe), :self_employed
        end

        should "return worried_about_work when going_to_work has been chosen" do
          @calculator.need_help_with = "going_to_work"
          assert_equal @calculator.next_question(:feel_safe), :worried_about_work
        end

        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:feel_safe), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:feel_safe), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:feel_safe), :nation
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

      context "user is on the are_you_off_work_ill node" do
        should "return have_somewhere_to_live when somewhere_to_live has been chosen" do
          @calculator.need_help_with = "somewhere_to_live"
          assert_equal @calculator.next_question(:are_you_off_work_ill), :have_somewhere_to_live
        end

        should "return mental_health_worries when mental_health has been chosen" do
          @calculator.need_help_with = "mental_health"
          assert_equal @calculator.next_question(:are_you_off_work_ill), :mental_health_worries
        end

        should "return nation when there are no other selected options" do
          @calculator.need_help_with = ""
          assert_equal @calculator.next_question(:are_you_off_work_ill), :nation
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
