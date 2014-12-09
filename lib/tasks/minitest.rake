require "rake/testtask"

namespace "test" do
  desc "Run default tests"
  Rake::TestTask.new("all") do |t|
    t.libs << "test"
    t.test_files = Dir["test/**/*_test.rb"]
  end
end
