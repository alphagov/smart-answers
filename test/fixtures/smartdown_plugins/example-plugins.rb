module SmartdownPlugins
  module ExamplePlugins
    extend ExampleIncludeable

    def self.multiply_by_10(arg_1)
      (arg_1.value * 10).to_i
    end
  end
end
