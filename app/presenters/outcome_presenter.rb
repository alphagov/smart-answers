require 'erubis'

class OutcomePresenter < NodePresenter
  include OutcomeHelper

  def title
    translate!('title')
  end

  def translate!(subkey)
    output = super(subkey)
    output.gsub!(/\+\[contact_list\]/,contact_list) unless output.nil?
    if output
      output.gsub!(/\+\[data_partial:(\w+):(\w+)\]/) do |match|
        render_data_partial($1, $2)
      end
    end

    output
  end

  def contact_list
    @contact_list = @node.contact_list_sym ? @state.send(@node.contact_list_sym) : []
    Erubis::Eruby.new( File.read Rails.root.join('app','views','smart_answers','_contact_list.html.erb') ).result(binding)
  end

  def has_calendar?
    ! @node.evaluate_calendar(@state).nil?
  end

  def calendar
    @node.evaluate_calendar(@state)
  end

  private

  def render_data_partial(partial, variable_name)
    data = @state.send(variable_name.to_sym)

    partial_path = ::SmartAnswer::FlowRegistry.instance.load_path.join("data_partials", "_#{partial}")
    ApplicationController.new.render_to_string(:file => partial_path.to_s, :layout => false, :locals => {variable_name.to_sym => data})
  end
end
