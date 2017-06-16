#!/usr/bin/env groovy

REPOSITORY = 'smart-answers'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    [$class: 'ParametersDefinitionProperty',
      parameterDefinitions: [
        [$class: 'BooleanParameterDefinition',
          name: 'IS_SCHEMA_TEST',
          defaultValue: false,
          description: 'Identifies whether this build is being triggered to test a change to the content schemas'],
        [$class: 'StringParameterDefinition',
          name: 'SCHEMA_BRANCH',
          defaultValue: DEFAULT_SCHEMA_BRANCH,
          description: 'The branch of govuk-content-schemas to test against'],
        [$class: 'BooleanParameterDefinition',
          name: 'RUN_REGRESSION_TESTS',
          defaultValue: false,
          description: 'Run regression tests, these are always run on the master branch, and by default disabled on other branches']]
    ],
  ])

  try {
    govuk.initializeParameters([
      'IS_SCHEMA_TEST': 'false',
      'SCHEMA_BRANCH': DEFAULT_SCHEMA_BRANCH,
    ])

    if (!govuk.isAllowedBranchBuild(env.BRANCH_NAME)) {
      return
    }
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

    if (env.BRANCH_NAME == 'master' || params.RUN_REGRESSION_TESTS) {
      stage('Regression tests') {
        govuk.setEnvar("RUN_REGRESSION_TESTS", "true")
        sh("bundle exec ruby test/regression/smart_answers_regression_test.rb")
      }
    }

    if (env.BRANCH_NAME == 'master') {
      stage('Push release tag') {
        govuk.pushTag(REPOSITORY, BRANCH_NAME, 'release_' + BUILD_NUMBER)
      }

      stage('Deploy to Integration') {
        // Deploy on Integration (only master)
        govuk.deployIntegration('smartanswers', BRANCH_NAME, 'release', 'deploy')
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
