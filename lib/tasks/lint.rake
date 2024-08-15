desc "Run all linters"
task lint: [:environment] do
  sh "bundle exec erblint --lint-all"
  sh "bundle exec rubocop --parallel"
  sh "yarn run lint"
end
