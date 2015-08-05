module SmartdownPlugins
  module AnimalExampleSimple
    extend DataPartial

    def self.data_simple_button(name)
      locals = {button_data: {url: '#', text: name}}
      render 'button', locals: locals
    end

    def self.old_lion_considered_potential_threat?(dob)
      (Date.current.year - Date.parse(dob.to_s).year) > 3
    end
  end
end
