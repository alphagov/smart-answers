module SmartdownHelper
  def get_smartanswer_content(question_name, started=false, responses=[])
    get_content(question_name, false, started, responses)
  end

  def get_smartdown_content(question_name, started=false, responses=[])
    get_content(question_name, true, started, responses)
  end

  def get_content(question_name, is_smartdown, started, responses)
    @controller.stubs(:smartdown_question).returns(is_smartdown)
    params = { id: question_name}
    if started
      params.merge!(started: "y")
    end
    unless responses.empty?
      params.merge!(responses: responses.join("/"))
    end
    get :show, params
    response.body
  end

  def get_file_as_string(filename)
    data = ''
    f = File.open(filename, "r")
    f.each_line do |line|
      data += line
    end
    data
  end

  def scenario_sequences(question_name)
    scenario_folder_path = Rails.root.join('lib', 'smartdown_flows', question_name, "scenarios", "*")
    scenario_strings = Dir[scenario_folder_path].map do |filename|
      get_file_as_string(filename).split("\n\n")
    end.flatten
    result = []
    scenario_strings.each do |scenario_string|
      responses = YAML::load(scenario_string+"\n").values.compact
      (0..responses.length).each do |i|
        result << responses[0..i]
      end
    end
    result.uniq!
    result
  end
end
