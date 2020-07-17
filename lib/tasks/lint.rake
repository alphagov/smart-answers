desc "Lint Ruby"
task lint: [:environment] do
  sh "bundle exec rubocop"
end
