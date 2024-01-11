require "test_helper"

class AllComponentsTest < ActionController::TestCase
  Dir.glob("app/views/components/*.erb").each do |filename|
    template = filename.split("/").last
    component_name = template.sub("_", "").sub(".html", "").sub(".erb", "").gsub("-", "_")

    context component_name do
      yaml_file = "#{__dir__}/../../app/views/components/docs/#{component_name}.yml"

      should "is documented" do
        assert File.exist?(yaml_file)
      end

      should "have the correct documentation" do
        yaml = YAML.unsafe_load_file(yaml_file)

        assert yaml["name"]
        assert yaml["description"]
        assert yaml["examples"]
        assert yaml["accessibility_criteria"] || yaml["shared_accessibility_criteria"]
      end

      should "have the correct class in the ERB template" do
        erb = File.read(filename)

        class_name = "app-c-#{component_name.dasherize}"

        assert_includes erb, class_name
      end

      should "have a correctly named template file" do
        template_file = "#{__dir__}/../../app/views/components/_#{component_name}.html.erb"

        assert File.exist?(template_file)
      end

      should "have a correctly named spec file" do
        rspec_file = "#{__dir__}/../../test/components/#{component_name.tr('-', '_')}_test.rb"

        assert File.exist?(rspec_file)
      end

      should "have a correctly named SCSS file" do
        css_file = "#{__dir__}/../../app/assets/stylesheets/components/_#{component_name.tr('_', '-')}.scss"

        assert File.exist?(css_file)
      end

      should "not use `html_safe`", not_applicable: component_name.in?(%w[govspeak]) do
        file = File.read(filename)

        assert_no_match file, "html_safe"
      end
    end
  end
end
