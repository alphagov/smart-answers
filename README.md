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

If you need to add a new worldwide organisations fixture find [it here](https://www.gov.uk/government/world/organisations) by the country name or its capital city, navigate to `<found_url>.json`, most likely it will be of the following format `https://www.gov.uk/api/world/organisations/british-[embassy|high-commission]-<capital city>`, copy over the JSON to `test/fixtures/worldwide/<country>_organisations.json` and change it to reflect the expected format based on other examples in the directory.

### Testing Smartdown flows

Smartdown flows are tested using [scenarios][smartdown-scenarios] in the flow directories.

Test all Smartdown flows by running:

    bundle exec ruby -Itest test/unit/smartdown_content/smartdown_scenarios_test.rb

Test a single Smartdown flow by running:

     SMARTDOWN_FLOW_TO_TEST=<name-of-smartdown-flow> \
     bundle exec ruby -Itest test/unit/smartdown_content/smartdown_scenarios_test.rb

[smartdown-scenarios]: https://github.com/alphagov/smartdown/blob/master/doc/scenarios.md

### Adding regression tests to Smart Answers

1. Generate a set of responses for the flow that you want to add regression tests to.

        $ rails r script/generate-questions-and-responses-for-smart-answer.rb <name-of-smart-answer>

2. Commit the generated questions-and-responses.yml file (in test/data) to git.

3. Change the file by adding/removing and changing the responses:

  * Add responses for any of the TODO items in the file.

  * Remove responses that you don't think cause the code to follow different branches, e.g. it might be useful to remove all but one (or a small number) of countries to avoid a combinatorial explosion of input responses.

  * Combine responses for checkbox questions where the effect of combining them doesn't affect the number of branches of the code that are exercised.

4. Commit the updated questions-and-responses.yml file to git.

5. Generate a set of input responses and expected results for the Smart Answer.

        $ rails r script/generate-responses-and-expected-results-for-smart-answer.rb <name-of-smart-answer>

6. Commit the generated responses-and-expected-results.yml file (in test/data) to git.

7. Run the regression test to generate the HTML of each outcome reached by the set of input responses.

        $ RUN_REGRESSION_TESTS=<name-of-smart-answer> \
          TEST_COVERAGE=true \
          ruby test/regression/smart_answers_regression_test.rb

8. Commit the generated outcome HTML files (in test/artefacts) to git.

9. Inspect the code coverage report for the Smart Answer under test (`open coverage/rcov/index.html` and find the smart answer under test).

  * If all the branches in the flow have been exercised then you don't need to do anything else at this time.

      * Code in node-level blocks (e.g. in `value_question`, `date_question`, `multiple_choice` & `outcome` blocks) will always be executed at *flow-definition-time*, and so coverage of these lines is of **no** significance when assessing test coverage of the flow logic.

      * Code in blocks inside node-level blocks (e.g. in `precalculate`, `next_node_calculation`, `validate` & `define_predicate` blocks) will be executed at *flow-execution-time*, and so coverage of these lines is of significance when assessing test coverage of the flow logic.

      * Coverage of code in ancillary classes (e.g. calculators) should also be considered at this point.

  * If there are branches in the flow that haven't been exercised then:

      * Determine the responses required to exercise those branches.

      * Go to Step 3, add the new responses and continue through the steps up to Step 9.

10. Generate a yaml file containing the set of source files that this Smart Answer depends upon. The script will automatically take the ruby flow file, locale file and erb templates into account. You just need to supply it with the location of any additional files required by the Smart Answer (e.g. calculators and data files). This data is used to determine whether to run the regression tests based on whether the source files have changed.

        $ rails r script/generate-checksums-for-smart-answer.rb <name-of-smart-answer> <path/to/additional/files>

11. Commit the generated yaml file to git.

## Issues/todos

Please see the [github issues](https://github.com/alphagov/smart-answers/issues) page.

## Making bigger changes

When making bigger changes that need to be tested before they go live it is best to release them as a draft first. There is a rake task for creating a draft flow `rake version:v2[flow]`. This is not ideal, but it allows to check the changes in the UI in the development and preview environments without affecting the production environment.

Once reviewed, the draft can be published by running `rake version:publish[flow]`. This merges V2 changes into the original files. Take a look at the [rake task](https://github.com/alphagov/smart-answers/blob/master/lib/tasks/version.rake) to see the details. If you used any other V2 files that are not covered by the rake task, make sure to process them manually.

### Commiting V2 -> V1 changes

To help developers track changes in files easily, it is best if you commit V2 files' removal in one commit, then commit the modifications to the original files. This creates an easy to browse diff of all the changes being published. Write a descriptive message for the second commit, as this is what the other developers will see in the file history.

### Detailed documentation

- [How to archive a Smart Answer](doc/archiving.md)

## Deploying to Heroku

The 'startup_heroku.sh' shell script will create and configure an app on Heroku, push the __current branch___ and open the marriage-abroad Smart Answer in the browser.

Once deployed you'll need to use the standard `git push` mechanism to deploy your changes.

    ./startup_heroku.sh
