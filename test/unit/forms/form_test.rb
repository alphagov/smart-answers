require "test_helper"

class FormTest < ActiveSupport::TestCase
  class TempForm < Form
    answer_flow :flow
    answer_node :node
  end

  def params
    @params ||= {}
  end

  def session
    @session ||= {}
  end

  def form_class
    @form_class ||= TempForm
  end

  def form
    @form ||= form_class.new(ActionController::Parameters.new(params), session)
  end

  should "raise error when options not defined" do
    assert_raise(Form::NotImplementedError) { form.options }
  end

  should "get flow name from class if defined" do
    assert_equal TempForm.flow_name, form.flow_name
  end

  should "get node name from class if defined" do
    assert_equal TempForm.node_name, form.node_name
  end

  context "when flow and node not defined at class" do
    setup do
      @form_class = Class.new(Form)
      @params = { flow_name: :some_flow, node_name: :some_node }
    end

    should "get flow name from params" do
      assert_equal params[:flow_name], form.flow_name
    end

    should "get node name from params" do
      assert_equal params[:node_name], form.node_name
    end
  end
end
