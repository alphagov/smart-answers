module FixtureMethods
  def fixture_file(filename)
    Rails.root.join("test/fixtures/#{filename}")
  end

  def read_fixture_file(filename)
    File.read(fixture_file(filename))
  end
end
