#!/usr/bin/env groovy

library("govuk@docker-accounts")

node {
  govuk.buildProject(
    repoName: 'smart-answers',
    brakeman: true,
  )
}
