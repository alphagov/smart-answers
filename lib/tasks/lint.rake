desc "Run all linters"
task lint: [:environment] do
  sh "bundle exec rubocop --parallel"
  sh "yarn run lint"
end
