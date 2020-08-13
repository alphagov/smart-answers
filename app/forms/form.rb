class Form
  include ActiveModel::Model
  include ActiveModel::Validations

  NotImplementedError = Class.new(StandardError)

  attr_accessor :session
  attr_reader :params

  class << self
    attr_reader :flow_name, :group_name, :node_name

    def answer_flow(flow_name)
      @flow_name = flow_name
    end

    def answer_node(node_name)
      @node_name = node_name
      attr_accessor node_name
    end

    def i18n_scope
      [:session_answers, flow_name, node_name]
    end

    def t(translation_name)
      I18n.t(translation_name, scope: i18n_scope)
    end
  end

  delegate :t, to: :class

  def initialize(params, session)
    @params = params
    @session = session
    assign_attributes_from_params
  end

  # if an attribute is assigned in a child class
  # for example:
  #
  #   `attr_accessor :foo`
  #
  # and params contains a value with matching key
  #
  #   params = { foo: :bar }
  #
  # Then that value will be assigned to the attribute
  #
  #   f = MyForm.new(params, {})
  #   f.foo => :bar
  def assign_attributes_from_params
    attributes_in_params = params.slice(*param_keys_that_match_attributes)
    attributes_in_params.permit!
    self.attributes = attributes_in_params
  end

  def param_keys_that_match_attributes
    keys_to_be_handled_separately = %w[flow_name node_name]
    keys_that_match_attributes = params.keys.select { |key| self.class.attribute_method?(key) }
    keys_that_match_attributes - keys_to_be_handled_separately
  end

  def flow_name
    @flow_name ||= self.class.flow_name || params[:flow_name]
  end

  def node_name
    @node_name ||= self.class.node_name || params[:node_name]
  end

  def options_for(type)
    options.map do |option|
      text = t("options.#{option}")
      text_key = type == :radio ? :text : :label
      { text_key => text, value: option }
    end
  end

  def checkbox_options
    options_for :checkbox
  end

  def radio_options
    options_for :radio
  end

  def options
    raise NotImplementedError, "The options method has not been defined"
  end

  def save
    prepare_session
    update_session if valid?
  end

  def prepare_session
    session[flow_name] ||= {}
  end

  def update_session
    session[flow_name][node_name] = data_to_be_stored_in_session
  end

  def data_to_be_stored_in_session
    params[node_name]
  end
end
