module SmartdownPlugins
  module AnimalExampleSimple
    extend DataPartial

    def self.data_simple_button(name)
      locals = {button_data: {url: '#', text: name}}
      render 'button', locals: locals
    end
  end
end
