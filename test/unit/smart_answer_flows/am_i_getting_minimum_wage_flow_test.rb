require_relative '../../test_helper'

require 'smart_answer_flows/am-i-getting-minimum-wage'

module SmartAnswer
  class AmIGettingMinimumWageFlowTest < ActiveSupport::TestCase
    setup do
      @flow = AmIGettingMinimumWageFlow.build
    end

    context 'validation' do
      [
        :how_old_are_you?,
        :how_old_were_you?
      ].each do |age_question_name|
        context "for #{age_question_name}" do
          setup do
            @question = @flow.node(age_question_name)
            @state = SmartAnswer::State.new(@question)
            @calculator = stub('calculator',
              :age= => nil,
              :under_school_leaving_age? => nil
            )
            @state.calculator = @calculator
          end

          should 'raise if the calculator says the age is invalid' do
            invalid_age = 0
            @calculator.stubs(:valid_age?).with(invalid_age).returns(false)
            assert_raise(SmartAnswer::InvalidResponse) do
              @question.transition(@state, invalid_age)
            end
          end

          should 'not raise if the calculator says the age is valid' do
            valid_age = 50
            @calculator.stubs(:valid_age?).with(valid_age).returns(true)
            assert_nothing_raised do
              @question.transition(@state, valid_age)
            end
          end
        end
      end

      [
        :how_often_do_you_get_paid?,
        :how_often_did_you_get_paid?
      ].each do |pay_frequency_question_name|
        context "for #{pay_frequency_question_name}" do
          setup do
            @question = @flow.node(pay_frequency_question_name)
            @state = SmartAnswer::State.new(@question)
            @calculator = stub('calculator',
              :pay_frequency= => nil
            )
            @state.calculator = @calculator
          end

          should 'raise if the calculator says the pay_frequency is invalid' do
            invalid_pay_frequency = 3
            @calculator.stubs(:valid_pay_frequency?).with(invalid_pay_frequency).returns(false)
            assert_raise(SmartAnswer::InvalidResponse) do
              @question.transition(@state, invalid_pay_frequency)
            end
          end

          should 'not raise if the calculator says the pay_frequency is valid' do
            valid_pay_frequency = 4
            @calculator.stubs(:valid_pay_frequency?).with(valid_pay_frequency).returns(true)
            assert_nothing_raised do
              @question.transition(@state, valid_pay_frequency)
            end
          end
        end
      end

      [
        :how_many_hours_do_you_work?,
        :how_many_hours_did_you_work?
      ].each do |hours_question_name|
        context "for #{hours_question_name}" do
          setup do
            @question = @flow.node(hours_question_name)
            @state = SmartAnswer::State.new(@question)
            @calculator = stub('calculator',
              pay_frequency: 1,
              :basic_hours= => nil
            )
            @state.calculator = @calculator
          end

          should 'use the error_hours error message' do
            @calculator.stubs(:valid_hours_worked?).returns(false)
            exception = assert_raise(SmartAnswer::InvalidResponse) do
              @question.transition(@state, '0')
            end
            assert_equal 'error_hours', exception.message
          end

          should 'raise if the calculator says the hours_worked is invalid' do
            invalid_hours_worked = 3
            @calculator.stubs(:valid_hours_worked?).with(invalid_hours_worked).returns(false)

            assert_raise(SmartAnswer::InvalidResponse) do
              @question.transition(@state, invalid_hours_worked)
            end
          end

          should 'not raise if the calculator says the hours_worked is valid' do
            valid_hours_worked = 4
            @calculator.stubs(:valid_hours_worked?).with(valid_hours_worked).returns(true)

            assert_nothing_raised do
              @question.transition(@state, valid_hours_worked)
            end
          end
        end
      end

      [
        :how_many_hours_overtime_do_you_work?,
        :how_many_hours_overtime_did_you_work?
      ].each do |overtime_hours_question_name|
        context "for #{overtime_hours_question_name}" do
          setup do
            @question = @flow.node(overtime_hours_question_name)
            @state = SmartAnswer::State.new(@question)
            @calculator = stub('calculator', :overtime_hours= => nil)
            @state.calculator = @calculator
          end

          should 'raise if the calculator says the overtime_hours_worked is invalid' do
            invalid_overtime_hours_worked = 3
            @calculator.stubs(:valid_overtime_hours_worked?).with(invalid_overtime_hours_worked).returns(false)

            assert_raise(SmartAnswer::InvalidResponse) do
              @question.transition(@state, invalid_overtime_hours_worked)
            end
          end

          should 'not raise if the calculator says the hours_worked is valid' do
            valid_overtime_hours_worked = 4
            @calculator.stubs(:valid_overtime_hours_worked?).with(valid_overtime_hours_worked).returns(true)

            assert_nothing_raised do
              @question.transition(@state, valid_overtime_hours_worked)
            end
          end
        end
      end

      [
        :current_accommodation_charge?,
        :past_accommodation_charge?
      ].each do |accommodation_charge_question_name|
        context "for #{accommodation_charge_question_name}" do
          setup do
            @question = @flow.node(accommodation_charge_question_name)
            @state = SmartAnswer::State.new(@question)
            @calculator = stub('calculator')
            @state.calculator = @calculator
          end

          should 'raise if the calculator says the accommodation_charge is invalid' do
            invalid_accommodation_charge = 3
            @calculator.stubs(:valid_accommodation_charge?).with(invalid_accommodation_charge).returns(false)

            assert_raise(SmartAnswer::InvalidResponse) do
              @question.transition(@state, invalid_accommodation_charge)
            end
          end

          should 'not raise if the calculator says the accommodation_charge is valid' do
            valid_accommodation_charge = 4
            @calculator.stubs(:valid_accommodation_charge?).with(valid_accommodation_charge).returns(true)

            assert_nothing_raised do
              @question.transition(@state, valid_accommodation_charge)
            end
          end
        end
      end

      [
        :current_accommodation_usage?,
        :past_accommodation_usage?
      ].each do |accommodation_usage_question_name|
        context "for #{accommodation_usage_question_name}" do
          setup do
            @question = @flow.node(accommodation_usage_question_name)
            @state = SmartAnswer::State.new(@question)
            @calculator = stub('calculator',
              accommodation_adjustment: nil,
              minimum_wage_or_above?: nil,
              historically_receiving_minimum_wage?: nil
            )
            @state.calculator = @calculator
          end

          should 'raise if the calculator says the accommodation_usage is invalid' do
            invalid_accommodation_usage = 3
            @calculator.stubs(:valid_accommodation_usage?).with(invalid_accommodation_usage).returns(false)

            assert_raise(SmartAnswer::InvalidResponse) do
              @question.transition(@state, invalid_accommodation_usage)
            end
          end

          should 'not raise if the calculator says the accommodation_usage is valid' do
            valid_accommodation_usage = 4
            @calculator.stubs(:valid_accommodation_usage?).with(valid_accommodation_usage).returns(true)

            assert_nothing_raised do
              @question.transition(@state, valid_accommodation_usage)
            end
          end
        end
      end
    end
  end
end
