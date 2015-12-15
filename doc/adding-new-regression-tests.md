# Adding new regression tests

1. Update the flow to replace any single line conditionals with multiple line conditionals. This is so that we get useful information from running the coverage utility. Single line conditionals will show up as having been exercised irrespective of whether the code they were guarding was exercised.

```ruby
# Replace single line conditional
array << :value if condition

# With multiple line alternative
if condition
  array << :value
end
```

2. Generate a set of responses for the flow that you want to add regression tests to.

```bash
$ rails r script/generate-questions-and-responses-for-smart-answer.rb \
  <name-of-smart-answer>
```

3. Commit the generated questions-and-responses.yml file (in test/data) to git.

4. Change the file by adding/removing and changing the responses:

  * Add responses for any of the TODO items in the file.

  * Remove responses that you don't think cause the code to follow different branches, e.g. it might be useful to remove all but one (or a small number) of countries to avoid a combinatorial explosion of input responses.

  * Combine responses for checkbox questions where the effect of combining them doesn't affect the number of branches of the code that are exercised.

5. Commit the updated questions-and-responses.yml file to git.

6. Generate a set of input responses and expected results for the Smart Answer.

```bash
$ rm -rf coverage && \
  TEST_COVERAGE=true \
  rails r script/generate-responses-and-expected-results-for-smart-answer.rb \
  <name-of-smart-answer>
```

7. Inspect the code coverage report for the Smart Answer under test (`open coverage/rcov/index.html` and find the smart answer under test).

  * If all the branches in the flow have been exercised then you don't need to do anything else at this time.

      * Code in node-level blocks (e.g. in `value_question`, `date_question`, `multiple_choice` & `outcome` blocks) will always be executed at *flow-definition-time*, and so coverage of these lines is of **no** significance when assessing test coverage of the flow logic.

      * Code in blocks inside node-level blocks (e.g. in `precalculate`, `next_node_calculation` & `validate` blocks) will be executed at *flow-execution-time*, and so coverage of these lines is of significance when assessing test coverage of the flow logic.

      * Coverage of code in ancillary classes (e.g. calculators) should also be considered at this point.

  * If there are branches in the flow that haven't been exercised then:

      * Determine the responses required to exercise those branches.

      * Go to Step 4, add the new responses and continue through the steps up to Step 7.

8. Commit the generated responses-and-expected-results.yml file (in test/data) to git.

9. Generate a yaml file containing the set of source files that this Smart Answer depends upon. The script will automatically take the ruby flow file, locale file and erb templates into account. You just need to supply it with the location of any additional files required by the Smart Answer (e.g. calculators and data files). This data is used to determine whether to run the regression tests based on whether the source files have changed.

```bash
$ rails r script/generate-checksums-for-smart-answer.rb \
  <name-of-smart-answer> \
  <path/to/additional/files>
```

10. Commit the generated yaml file to git.

11. Run the regression test to generate the Govspeak of each landing page and outcome reached by the set of input responses.

```bash
$ RUN_REGRESSION_TESTS=<name-of-smart-answer> \
  ruby test/regression/smart_answers_regression_test.rb
```

If you want individual tests to fail early when differences are detected, set `ASSERT_EACH_ARTEFACT=true`.
Note that this more than doubles the time it takes to run regression tests.

12. Commit the generated Govspeak files (in test/artefacts) to git.
