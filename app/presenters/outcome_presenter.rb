require 'erubis'

class OutcomePresenter < NodePresenter

  def title
    translate!('title')
  end

  def translate!(subkey)
    output = super(subkey)
    if output
      output.gsub!(/\+\[data_partial:(\w+):(\w+)\]/) do |match|
        render_data_partial($1, $2)
      end
    end

    output
  end

  def calendar
    @node.defined_calendar
  end

  def has_calendar?
    calendar.present?
  end

  def calendar_as_ics
    calendar.to_ics @node.evaluate_calendar(@state)
  end

  private

  def render_data_partial(partial, variable_name)
    data = @state.send(variable_name.to_sym)

    partial_path = ::SmartAnswer::FlowRegistry.instance.load_path.join("data_partials", "_#{partial}")
    ApplicationController.new.render_to_string(:file => partial_path.to_s, :layout => false, :locals => {variable_name.to_sym => data})
  end
end
