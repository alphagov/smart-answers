desc "Run Brakeman"
task security: [:environment] do
  sh "bundle exec brakeman . --except CheckRenderInline"
end
