#!/usr/bin/env groovy

library("govuk")

node {

  govuk.buildProject(
    sassLint: false,
    repoName: 'smart-answers',
    brakeman: true,
    rubyLintDiff: false,
    afterTest: { sh("bundle exec whenever --update-crontab") },
  )
}
