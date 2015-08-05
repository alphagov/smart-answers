require 'fileutils'

namespace :version do
  DELIM = "********************************************"
  USAGE = "rake version:<task>['<flow name>']"
  NO_FLOW_NAME_ERR_MSG = "Please supply a flow name.\n\n$ #{USAGE}"
  FLOWS_PATH = File.join(File.dirname(__FILE__), '../', 'smart_answer_flows/')
  CALCULATORS_PATH = File.join(File.dirname(__FILE__), '../', 'smart_answer/calculators/')
  TEST_PATH = File.join(File.dirname(__FILE__), '../../', 'test/')
  FLOWS_TEST_PATH = File.join(TEST_PATH, 'integration/smart_answer_flows/')
  UNIT_TEST_PATH = File.join(TEST_PATH, 'unit/calculators/')
  LOCALES_PATH = File.join(FLOWS_PATH, "locales/en/")

  def raise_error(msg)
    raise [DELIM, msg, DELIM, "\n"].join("\n")
  end

  def no_flow_name_error
    raise_error(NO_FLOW_NAME_ERR_MSG)
  end

  def flow_path(flow, version = '')
    version = "-#{version}" unless version.empty?
    "#{FLOWS_PATH}#{flow}#{version}.rb"
  end

  def yml_path(flow, version = '')
    version = "-#{version}" unless version.empty?
    "#{LOCALES_PATH}#{flow}#{version}.yml"
  end

  def flow_test_path(flow, version = '')
    version = "_#{version}" unless version.empty?
    "#{FLOWS_TEST_PATH}#{flow.gsub('-', '_')}#{version}_test.rb"
  end

  def replace_in_file(filepath, replacements)
    if File.exists?(filepath)
      text = File.read(filepath)
      replacements.each do |regex, replacement|
        text.gsub!(regex, replacement)
      end
      File.open(filepath, "w") {|file| file.puts text}
    end
  end

  def version_flow_dependencies(flow_data)
    calculators = []

    # Update any class dependencies to V2s
    flow_data.gsub!(/Calculators::[aA-zZ]+(Calculator|DataQuery)/) do |match|
      puts "Updating #{match} with #{match}V2"
      calculators << match
      "#{match}V2"
    end

    [flow_data, calculators]
  end

  def process_calculators(calculators, publish = false)
    calculators.uniq.each do |calc|
      class_name = calc.split("::").last
      filename = class_name.underscore
      filepath = File.join(CALCULATORS_PATH, "#{filename}.rb")
      v2_filepath = File.join(CALCULATORS_PATH, "#{filename}_v2.rb")
      test_filepath = File.join(UNIT_TEST_PATH, "#{filename}_test.rb")
      v2_test_filepath = File.join(UNIT_TEST_PATH, "#{filename}_v2_test.rb")

      if publish
        if File.exists?(v2_filepath)
          FileUtils.mv(v2_filepath, filepath)
          puts "Moved #{v2_filepath} to #{filepath}"
        end
        if File.exists?(v2_test_filepath)
          FileUtils.mv(v2_test_filepath, test_filepath)
          puts "Moved #{v2_test_filepath} to #{test_filepath}"
        end
        replace_in_file(filepath, "#{class_name}V2" => class_name)
        replace_in_file(test_filepath, "#{class_name}V2" => class_name)
        replace_in_file(test_filepath, "#{class_name}V2Test" => "#{class_name}Test")
      else
        if File.exists?(filepath)
          FileUtils.cp(filepath, v2_filepath)
          puts "Created #{v2_filepath}"
        end
        if File.exists?(test_filepath)
          FileUtils.cp(test_filepath, v2_test_filepath)
          puts "Created #{v2_test_filepath}"
        end
        replace_in_file(v2_filepath, class_name => "#{class_name}V2")
        replace_in_file(v2_test_filepath, class_name => "#{class_name}V2")
        replace_in_file(v2_test_filepath, "#{class_name}Test" => "#{class_name}V2Test")
      end
    end
  end

  desc "Turns a version 2 draft flow into a published flow"
  task :publish, [:flow] => [:environment] do |t, args|
    flow = args[:flow]
    no_flow_name_error unless flow
    raise_error("No v2 found for '#{flow}'") unless File.exists?(flow_path(flow, 'v2'))

    # Move the v2 files
    FileUtils.mv(flow_path(flow, 'v2'), flow_path(flow))
    puts "Moved #{flow_path(flow, 'v2')} to #{flow_path(flow)}"
    FileUtils.mv(yml_path(flow, 'v2'), yml_path(flow))
    puts "Moved #{yml_path(flow, 'v2')} to #{yml_path(flow)}"
    FileUtils.mv(flow_test_path(flow, 'v2'), flow_test_path(flow))
    puts "Moved #{flow_test_path(flow, 'v2')} to #{flow_test_path(flow)}"

    # Rename the internals
    replace_in_file(flow_path(flow), { /V2/ => '' })
    replace_in_file(yml_path(flow), { Regexp.new("#{flow}-v2:") => "#{flow}:" })
    replace_in_file(flow_test_path(flow), { /V2/ => '', Regexp.new("#{flow}-v2") => flow })

    flow_data = File.read(flow_path(flow))
    flow_data.gsub!("status :draft", "status :published")
    puts "Set flow status to published"

    calculators = flow_data.scan(/(Calculators::[aA-zZ]+(Calculator|DataQuery))/).map(&:first).uniq
    process_calculators(calculators, true)

    File.open(flow_path(flow), "w") {|file| file.puts flow_data}

    puts `git status`
  end

  desc "Makes a version 2 draft flow"
  task :v2, [:flow] => [:environment] do |t, args|
    flow = args[:flow]
    no_flow_name_error unless flow
    raise_error("V2 already found for '#{flow}'") if File.exists?(flow_path(flow, 'v2'))

    # Create the v2 files
    FileUtils.cp(flow_path(flow), flow_path(flow, 'v2'))
    puts "Created #{flow_path(flow, 'v2')}"
    FileUtils.cp(yml_path(flow), yml_path(flow, 'v2'))
    puts "Created #{yml_path(flow, 'v2')}"
    FileUtils.cp(flow_test_path(flow), flow_test_path(flow, 'v2'))
    puts "Created #{flow_test_path(flow, 'v2')}"

    # Set the flow to draft
    flow_data = File.read(flow_path(flow, 'v2'))

    flow_data.gsub!("status :published", "status :draft")
    puts "Set v2 flow as draft"

    flow_data, calculators = version_flow_dependencies(flow_data)
    process_calculators(calculators)

    File.open(flow_path(flow, 'v2'), "w") {|file| file.puts flow_data}

    # Replace yml key
    replace_in_file(yml_path(flow, 'v2'), { Regexp.new("#{flow}:") => "#{flow}-v2:" })

    # Update class name for integration test and setup flow name
    test_data = File.read(flow_test_path(flow, 'v2'))

    test_data.gsub!(/([aA-zZ]+)Test /) { "#{$1}V2Test " }
    test_data.gsub!(flow, "#{flow}-v2")
    puts "Renamed test class and setup flow"

    File.open(flow_test_path(flow, 'v2'), "w") {|file| file.puts test_data}

    puts `git status`
  end
end
