require 'test_helper'
require 'smartdown_plugins/shared/data_partial'

module SmartdownPlugins
  class DataPartialTest < ActiveSupport::TestCase
    def data_partial_template_directory
      File.join(Rails.root, 'test', 'fixtures', 'smart_answer_flows', 'data_partials')
    end

    def subject
      Module.new do
        extend DataPartial
      end
    end

    test ".render renders a template" do
      locals = {sample_data: {'address' => '1 Doge\'s Palace', 'phone' => '999'}}
      output = subject.render('scalar_partial',
        directory: data_partial_template_directory,
        locals: locals)
      expected_output = <<-expectedoutput
## An address

$A
1 Doge's Palace
$A

## And a phone number

$C
999
$C
expectedoutput

      assert_equal expected_output, output
    end
  end
end
