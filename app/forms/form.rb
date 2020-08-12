class Form
  include ActiveModel::Model
  include ActiveModel::Validations

  NotImplementedError = Class.new(StandardError)

  attr_accessor :session
  attr_reader :params, :question_name, :flow_name

  class << self
    attr_reader :flow_name, :node_name

    def answer_flow(flow_name)
      @flow_name = flow_name
    end

    def answer_node(node_name)
      @node_name = node_name
    end
  end

  delegate :flow_name, :node_name, to: :class

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
    self.attributes = params.select { |k, _| self.class.attribute_method?(k) }
  end

  def checkbox_options
    options.each_with_object([]) do |(key, value), array|
      array << { label: value, value: key.to_s }
    end
  end

  def radio_options
    options.each_with_object([]) do |(key, value), array|
      array << { text: value, value: key.to_s }
    end
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
