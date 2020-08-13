class CoronavirusFindSupportFlow
  NODES = {
    need_help_with: :feel_safe,
    feel_safe: :afford_rent_mortgage_bills,
    afford_rent_mortgage_bills: :afford_food,
    afford_food: :get_food,
    get_food: :able_to_go_out,
    able_to_go_out: :self_employed,
    self_employed: :have_you_been_made_unemployed,
    have_you_been_made_unemployed: :are_you_off_work_ill,
    are_you_off_work_ill: :worried_about_work,
    worried_about_work: :have_somewhere_to_live,
    have_somewhere_to_live: :have_you_been_evicted,
    have_you_been_evicted: :mental_health_worries,
    mental_health_worries: :nation,
    nation: :results,
    results: :unknown,
  }.freeze

  attr_reader :node_name
  def initialize(node_name)
    @node_name = node_name.to_sym
  end

  def next_node
    NODES[node_name]
  end

  def has_node?
    NODES.keys.include?(node_name)
  end
end
