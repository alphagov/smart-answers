#!/usr/bin/env groovy

library("govuk")

node {

  govuk.buildProject(
    sassLint: false,
    repoName: 'smart-answers',
    overrideTestTask: {
      stage("Run tests") {
        govuk.runTests()
      }

      if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME.startsWith('dependabot/') || params.RUN_REGRESSION_TESTS) {
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
