# Smart Answers

## Introduction

> Smart answers are a great tool for content designers to present complex information in a quick and simple way. Defining what they are – decision trees? calculators? tools? is immaterial – what they do is provide a reusable technical framework to build a quick and simple answer to a complex question.

Read more in [a blog post](https://gds.blog.gov.uk/2012/02/16/smart-answers-are-smart/).

Have a look at
[`test/unit/flow_test.rb`](test/unit/flow_test.rb) for example usage.

This application supports two styles of writing and executing smart answers:

### Ruby and YAML-based smart answer flows

For more information, please go to the [Ruby/YAML SmartAnswer README](lib/smart_answer_flows/README.md)

### Smartdown-based smart answer flows

For more information, please go to the [Smartdown SmartAnswer README](lib/smartdown_flows/README.md)

### Switching from one style to another

Smart answers are by default expected to be in Ruby/YAML style.
To transition a smart answer from Ruby/YML to Smartdown style, register it in the smartdown registry (`lib/smartdown/registry.rb`).

## Debugging current state

If you have a URL of a Smart answer and want to debug the state of it i.e. to see PhraseList keys, saved inputs, the outcome name, append `debug=1` query parameter to the URL in development mode. This will render debug information on the Smart answer page.

## Visualising a flow

To see an interactive visualisation of a smart answer flow, append `/visualise` to the root of a smartanswer URL e.g. `http://smartanswers.dev.gov.uk/<my-flow>/visualise/`

To see a static visualisation of a smart answer flow, using Graphviz:

    # Download graphviz representation
    $ curl https://www.gov.uk/marriage-abroad/visualise.gv --silent > /tmp/marriage-abroad.gv

    # Use Graphviz to generate a PNG
    $ dot /tmp/marriage-abroad.gv -Tpng > /tmp/marriage-abroad.png

    # Open the PNG
    $ open /tmp/marriage-abroad.png

__NOTE.__ This assumes you already have Graphviz installed. You can install it using Homebrew on a Mac (`brew install graphviz`).

## Installing and running

NB: this assumes you are running on the GOV.UK virtual machine, not your host.

```bash
  ./install # git fetch from each dependency dir and bundle install
```

Run using bowler on VM from cd /var/govuk/development:
```
bowl smartanswers
```

## Viewing a Smart Answer

To view a smart answer locally if running using bowler http://smartanswers.dev.gov.uk/register-a-birth

## Testing

Run unit tests by executing the following:

    bundle exec rake

### Fixtures

If you need to update the world locations fixture, run the following command:

    $ rails r script/update-world-locations.rb

If you need to add/update a worldwide organisations fixture, run the following command:

    $ rails r script/update-worldwide-location-organisations.rb <location-slug>

### Testing Smartdown flows

Smartdown flows are tested using [scenarios][smartdown-scenarios] in the flow directories.

Test all Smartdown flows by running:

    bundle exec ruby -Itest test/unit/smartdown_content/smartdown_scenarios_test.rb

Test a single Smartdown flow by running:

     SMARTDOWN_FLOW_TO_TEST=<name-of-smartdown-flow> \
     bundle exec ruby -Itest test/unit/smartdown_content/smartdown_scenarios_test.rb

[smartdown-scenarios]: https://github.com/alphagov/smartdown/blob/master/doc/scenarios.md

### Adding regression tests to Smart Answers

1. Update the flow to replace any single line conditionals around `Phraselist`s with multiple line conditionals. This is so that we get useful information from the running the coverage utility. Single line conditionals will show up as having been exercised irrespective of whether they caused something to be added to the `Phraselist`.

        # Replace single line conditional
        phrases << :new_phrase if condition

        # With multiple line alternative
        if condition
          phrases << :new_phrase
        end

2. Generate a set of responses for the flow that you want to add regression tests to.

        $ rails r script/generate-questions-and-responses-for-smart-answer.rb \
          <name-of-smart-answer>

3. Commit the generated questions-and-responses.yml file (in test/data) to git.

4. Change the file by adding/removing and changing the responses:

  * Add responses for any of the TODO items in the file.

  * Remove responses that you don't think cause the code to follow different branches, e.g. it might be useful to remove all but one (or a small number) of countries to avoid a combinatorial explosion of input responses.

  * Combine responses for checkbox questions where the effect of combining them doesn't affect the number of branches of the code that are exercised.

5. Commit the updated questions-and-responses.yml file to git.

6. Generate a set of input responses and expected results for the Smart Answer.

        $ rm -rf coverage && \
          TEST_COVERAGE=true \
          rails r script/generate-responses-and-expected-results-for-smart-answer.rb \
          <name-of-smart-answer>

7. Inspect the code coverage report for the Smart Answer under test (`open coverage/rcov/index.html` and find the smart answer under test).

  * If all the branches in the flow have been exercised then you don't need to do anything else at this time.

      * Code in node-level blocks (e.g. in `value_question`, `date_question`, `multiple_choice` & `outcome` blocks) will always be executed at *flow-definition-time*, and so coverage of these lines is of **no** significance when assessing test coverage of the flow logic.

      * Code in blocks inside node-level blocks (e.g. in `precalculate`, `next_node_calculation`, `validate` & `define_predicate` blocks) will be executed at *flow-execution-time*, and so coverage of these lines is of significance when assessing test coverage of the flow logic.

      * Coverage of code in ancillary classes (e.g. calculators) should also be considered at this point.

  * If there are branches in the flow that haven't been exercised then:

      * Determine the responses required to exercise those branches.

      * Go to Step 4, add the new responses and continue through the steps up to Step 7.

8. Commit the generated responses-and-expected-results.yml file (in test/data) to git.

9. Generate a yaml file containing the set of source files that this Smart Answer depends upon. The script will automatically take the ruby flow file, locale file and erb templates into account. You just need to supply it with the location of any additional files required by the Smart Answer (e.g. calculators and data files). This data is used to determine whether to run the regression tests based on whether the source files have changed.

        $ rails r script/generate-checksums-for-smart-answer.rb \
          <name-of-smart-answer> \
          <path/to/additional/files>

10. Commit the generated yaml file to git.

11. Run the regression test to generate the HTML of each outcome reached by the set of input responses.

        $ RUN_REGRESSION_TESTS=<name-of-smart-answer> \
          ruby test/regression/smart_answers_regression_test.rb

12. Commit the generated outcome HTML files (in test/artefacts) to git.

## Making bigger changes

When making bigger changes that need to be tested or fact-checked before they are deployed to GOV.UK it is best to deploy the branch with changes to Heroku.

If you open a PR to review those changes, make sure to mention if it's being fact-checked and should not be merged to master until that's done.

### Deploying to Heroku

The 'startup_heroku.sh' shell script will create and configure an app on Heroku, push the __current branch__ and open the marriage-abroad Smart Answer in the browser.

Once deployed you'll need to use the standard `git push` mechanism to deploy your changes.

    ./startup_heroku.sh

### Alternatives

If you can not deploy on Heroku, it is possible to use the now deprecated [V2 workflow](https://github.com/alphagov/smart-answers/blob/38f48bdd77f3a9f1c6319c6ab76149fa8dc8e909/README.md#making-bigger-changes).

## Merging a pull request from the Content Team

### Introduction

Members of the Content Team do not have permission to contribute directly to the canonical repository, so when they want to make a change, they create a pull request using a fork of the repository. Also since they don't usually have a Ruby environment setup on their local machine, they will not be able to update
files relating to the regression tests e.g. file checksums, HTML artefacts, etc. See documentation about [adding regression tests](#adding-regression-tests-to-smart-answers) for more information.

## Instructions

1. Check out the branch from the forked repo onto your local machine. Note that `<github-username>` refers to the owner 

    $ git remote add <owner-of-forked-repo> git@github.com:<owner-of-forked-repo>/smart-answers.git
    $ git fetch <owner-of-forked-repo>
    $ git co -b <branch-on-local-repo> <owner-of-forked-repo>/<branch-on-forked-repo>

2. Review the changes in the commit(s)
3. Remove any trailing whitespace
4. Run the following command to re-generate the HTML artefacts for the regression tests:

    $ RUN_REGRESSION_TESTS=<smart-answer-flow-name> ruby test/regression/smart_answers_regression_test.rb

5. Review the changes to the HTML artefacts to check they are as expected
6. Run the following command to update the checksums for the smart answer:

    $ rails r script/generate-checksums-for-smart-answer.rb <smart-answer-flow-name>

7. Run the main test suite

    $ rake

8. Stage the changed files & add a new commit or amend the commit

    $ git add .
    $ git commit # ok to amend commit if only one commit in PR

9. Run the regression test for the smart answer (now that HTML artefacts & file checksums have been updated)

    $ RUN_REGRESSION_TESTS=<smart-answer-flow-name> ruby test/regression/smart_answers_regression_test.rb

10. Push the branch to GitHub and submit a new pull request so that people have a chance to review the changes and a Continuous Integration build is triggered. Close the original pull request.

    $ git push origin <branch-on-local-repo>

## Archiving a Smart Answer

- [How to archive a Smart Answer](doc/archiving.md)

## Issues/todos

Please see the [github issues](https://github.com/alphagov/smart-answers/issues) page.
