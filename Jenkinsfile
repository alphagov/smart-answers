#!/usr/bin/env groovy

library("govuk")

node {

  govuk.buildProject(
    sassLint: false,
    repoName: 'smart-answers',
    brakeman: true,
    rubyLintDiff: false,
  )
}
