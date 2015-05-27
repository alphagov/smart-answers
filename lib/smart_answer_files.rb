class SmartAnswerFiles
  def initialize(flow_name)
    @flow_name = flow_name
  end

  def paths
    [flow_path, locale_path]
  end

  private

  def flow_path
    File.join('lib', 'smart_answer_flows', "#{@flow_name}.rb")
  end

  def locale_path
    File.join('lib', 'smart_answer_flows', 'locales', 'en', "#{@flow_name}.yml")
  end
end
