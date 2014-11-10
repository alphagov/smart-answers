module SmartdownPlugins
  module AnimalExampleSimple
    extend DataPartial

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
  end
end
