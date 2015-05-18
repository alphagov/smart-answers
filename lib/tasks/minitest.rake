require "rake/testtask"

namespace "test" do
  desc "Run default tests"
  Rake::TestTask.new("all") do |t|
    t.libs << "test"
    t.test_files = Dir["test/**/*_test.rb"]
  end
end

task :test do
  Rake::Task['test:all'].invoke
end

# Override the default task
task default: [] # Just in case it hasn't already been set
Rake::Task[:default].clear
task default: "test:all"
