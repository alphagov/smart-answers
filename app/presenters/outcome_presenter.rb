require 'erubis'

class OutcomePresenter < NodePresenter
  include OutcomeHelper

  def translate!(subkey)
    output = super(subkey)
    output.gsub!(/\+\[contact_list\]/,contact_list) unless output.nil?

    output
  end

  def contact_list
    @contact_list = @node.contact_list_sym ? @state.send(@node.contact_list_sym) : []
    Erubis::Eruby.new( File.read Rails.root.join('app','views','smart_answers','_contact_list.html.erb') ).result(binding)
  end

end
