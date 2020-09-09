desc "Run Javascript tests"
task js_test: [:environment] do
  sh "rake jasmine:ci"
end
