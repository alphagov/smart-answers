#!/usr/bin/env groovy

REPOSITORY = 'smart-answers'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  try {
    stage('Checkout') {
      checkout scm
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
      govuk.contentSchemaDependency()
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")
      govuk.setEnvar("DISPLAY", ":99")
    }

    stage('Bundle') {
      govuk.bundleApp()
    }

    stage('Linter') {
      govuk.rubyLinter()
    }

    stage("Assets") {
      govuk.precompileAssets()
    }

    stage('Tests') {
      govuk.runTests()
    }

    if (env.BRANCH_NAME == 'master') {
      stage('Push release tag') {
        govuk.pushTag(REPOSITORY, BRANCH_NAME, 'release_' + BUILD_NUMBER)
      }

      stage('Deploy to Integration') {
        // Deploy on Integration (only master)
        govuk.deployIntegration(REPOSITORY, BRANCH_NAME, 'release', 'deploy')
      }
    }

  } catch (e) {
    currentBuild.result = 'FAILED'
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
