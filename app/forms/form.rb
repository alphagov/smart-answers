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
    session[:flow_name] ||= {}
    session[:flow_name][:node_name] = params[:node_name]
  end
end
