#!/usr/bin/env groovy

library("govuk")

node {

  govuk.buildProject(
    sassLint: false,
    repoName: 'smart-answers',
    overrideTestTask: {
      stage("Check responses and expected results file for changes") {
        sh("bundle exec rails runner script/generate-responses-and-expected-results-for-smart-answer.rb marriage-abroad")
        def output = sh(script: "git status --short -- test/data/marriage-abroad-responses-and-expected-results.yml", returnStdout: true)

        if (output?.trim()) {
          def message = "'Expected results' file not generated for marriage abroad, please see docs/flattening-outcomes.md"
          echo message
          setBuildStatus(jobName, govuk.getFullCommitHash(), message, "FAILURE", repoName)
        }
      }

      stage("Run tests") {
        govuk.runTests()
      }

      if (env.BRANCH_NAME == 'master' || params.RUN_REGRESSION_TESTS) {
        stage('Regression tests') {
          govuk.setEnvar("RUN_REGRESSION_TESTS", "true")
          sh("bundle exec ruby test/regression/smart_answers_regression_test.rb")
        }
      }
    },
    brakeman: true,
    extraParameters: [
      [$class: 'BooleanParameterDefinition',
        name: 'RUN_REGRESSION_TESTS',
        defaultValue: false,
        description: 'Run regression tests, these are always run on the master branch, and by default disabled on other branches']
    ],
  )
}
