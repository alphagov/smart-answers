require_relative "../test_helper"
require_relative "../fixtures/smart_answer_flows/graph"

module SmartAnswer
  class GraphPresenterTest < ActiveSupport::TestCase
    setup do
      setup_fixture_flows
      @flow = SmartAnswer::GraphFlow.build
      @presenter = GraphPresenter.new(@flow)
    end

    teardown do
      teardown_fixture_flows
    end

    test "presents labels of graph flow" do
      expected_labels = {
        q1?: "Radio\n-\nWhat is the answer to q1?\n\n( ) yes\n( ) no",
        q2?: "Radio\n-\nWhat is the answer to q2?\n\n( ) a\n( ) b",
        q_with_interpolation?: "Radio\n-\nQuestion with <%= inter.pol.ation %>?\n\n( ) x\n( ) y",
        done_a: "Outcome\n-\ndone_a",
        done_b: "Outcome\n-\ndone_b",
      }

      assert_equal expected_labels, @presenter.labels
    end

    test "presents adjacency_list of simple graph" do
      expected_adjacency_list = {
        q1?: [[:q2?, ""]],
        q2?: [[:done_a, ""], [:q_with_interpolation?, ""]],
        q_with_interpolation?: [[:done_b, ""]],
        done_a: [],
        done_b: [],
      }

      assert_equal expected_adjacency_list, @presenter.adjacency_list
    end

    test "indicates does not define transitions in a way which can be visualised" do
      p = GraphPresenter.new(SmartAnswer::GraphFlow.build)
      assert p.visualisable?, "'graph' should be visualisable"
    end

    test "#title returns the title of the flow" do
      assert_equal "Graph Flow", @presenter.title
    end
  end
end
