require_relative '../test_helper'

class SmartAnswerHasherTest < ActiveSupport::TestCase
  should "raise an exception if any of the paths don't exist" do
    non_existent_file = '/path/to/non-existent/file'
    assert_raises(SmartAnswerHasher::FileNotFound) do
      SmartAnswerHasher.new([non_existent_file])
    end
  end

  should 'generate yaml file containing md5 hash of each file relating to a smart answer' do
    flow_files_content = [
      'flow-file-content',
      'template-file-content',
      'calculator-file-content'
    ]

    with_smart_answer_flow_files(flow_files_content) do |flow_files_paths_and_contents|
      flow_file_paths = flow_files_paths_and_contents.keys
      hasher = SmartAnswerHasher.new(flow_file_paths)

      buffer = StringIO.new
      hasher.write_checksum_data(buffer)
      buffer.rewind

      checksum_data = YAML.load(buffer.read)

      flow_files_paths_and_contents.each do |(path, content)|
        assert_equal Digest::MD5.hexdigest(content), checksum_data[path]
      end
    end
  end

private

  def with_smart_answer_flow_files(flow_files_content)
    begin
      flow_files_paths_and_contents = {}
      flow_files = flow_files_content.collect do |content|
        file = Tempfile.new(content)

        flow_files_paths_and_contents[file.path] = content

        file.write content
        file.rewind
        file
      end

      yield flow_files_paths_and_contents
    ensure
      flow_files.each do |file|
        file.unlink
        file.close
      end
    end
  end
end
