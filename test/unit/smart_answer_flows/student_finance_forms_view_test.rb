require_relative '../../test_helper'

require 'smart_answer_flows/student-finance-forms'

module SmartAnswer
  class StudentFinanceFormsViewTest < ActiveSupport::TestCase
    setup do
      @flow = StudentFinanceFormsFlow.build
      @i18n_prefix = "flow.#{@flow.name}"
    end

    def question_presenter(question_name)
      question = @flow.node(question_name)
      state = SmartAnswer::State.new(question)
      QuestionPresenter.new(question, state)
    end

    context 'when rendering :continuing_student? question' do
      should 'display Yes and No options' do
        assert_equal ['No', 'Yes'], question_presenter(:continuing_student?).options.map(&:label).sort
      end
    end

    context 'when rendering :pt_course_start? question' do
      should 'display Yes and No options' do
        assert_equal ['No', 'Yes'], question_presenter(:pt_course_start?).options.map(&:label).sort
      end
    end
  end
end
