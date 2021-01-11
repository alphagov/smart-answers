#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    beforeTest: { sh("yarn install") },
    sassLint: false,
    repoName: 'smart-answers',
    brakeman: true,
  )
}
