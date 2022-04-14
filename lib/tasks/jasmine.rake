desc "Run Javascript tests"
task jasmine: [:environment] do
  sh "yarn run jasmine:ci"
end
