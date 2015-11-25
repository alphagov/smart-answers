require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'

require 'fixtures/smart_answer_flows/graph'

module SmartAnswer
  class GraphPresenterTest < ActiveSupport::TestCase
    include I18nTestHelper

    setup do
      use_additional_translation_file(fixture_file('smart_answer_flows/locales/en/graph.yml'))

      @flow = SmartAnswer::GraphFlow.new
      @flow.use_i18n_templates_for_questions
      @flow.define
      @presenter = GraphPresenter.new(@flow)
    end

    teardown do
      reset_translation_files
    end

    test "presents labels of simple graph" do
      expected_labels = {
        q1?: "MultipleChoice\n-\nWhat is the answer to q1?\n\n( ) yes\n( ) no",
        q2?: "MultipleChoice\n-\nWhat is the answer to q2?\n\n( ) a\n( ) b",
        q_with_interpolation?: "MultipleChoice\n-\nQuestion with %{interpolation}?\n\n( ) x\n( ) y",
        done_a: "Outcome\n-\ndone_a",
        done_b: "Outcome\n-\ndone_b"
      }

      assert_equal expected_labels, @presenter.labels
    end

    test "presents adjacency_list of simple graph" do
      expected_adjacency_list = {
        q1?: [[:q2?, ""]],
        q2?: [[:done_a, ''], [:q_with_interpolation?, '']],
        q_with_interpolation?: [[:done_b, ""]],
        done_a: [],
        done_b: []
      }

      assert_equal expected_adjacency_list, @presenter.adjacency_list
    end

    test "indicates does not define transitions in a way which can be visualised" do
      p = GraphPresenter.new(SmartAnswer::GraphFlow.build)
      assert p.visualisable?, "'graph' should be visualisable"
    end
  end
end
