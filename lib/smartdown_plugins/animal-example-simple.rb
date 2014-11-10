module SmartdownPlugins
  module AnimalExampleSimple

    def self.data_simple_button(_)
      locals = {button_data: {url: 'hello', text: 'hello'}}
      render 'button', locals: locals
    end

    def self.data_embassy(country_name)
      location = ::WorldLocation.find('afghanistan')
      organisation = location.fco_organisation
      overseas_passports_embassies = organisation.offices_with_service 'Registrations of Marriage and Civil Partnerships'
      locals = {overseas_passports_embassies: overseas_passports_embassies}
      render 'overseas_passports_embassies', locals: locals
    end

    def self.render(template_name, opts={})
      locals = opts.fetch(:locals, nil)
      ApplicationController.new.render_to_string(
        :file => File.join(Rails.root, 'lib', 'smart_answer_flows', 'data_partials', "_#{template_name}.erb"),
        :layout => false,
        :locals => locals
      )
    end
  end
end
