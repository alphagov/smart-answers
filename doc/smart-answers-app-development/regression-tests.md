# Regression tests

## Overview

Unusually this project includes a set of regression tests. These tests are not *normally* run as part of the `default` Rake task, because they take a long time to run. Thus they do not normally run as part of the [main CI build](continuous-integration#main). However, they *always* run as part of the [regression CI build](continuous-integration#regression) on the master branch only.

### Running regression tests on CI

Go to this [Jenkins Job](https://ci.integration.publishing.service.gov.uk/job/smartanswers/job/master/), and choose `Build with parameters`. You can select the option `RUN_REGRESSION_TESTS` to include running the regression tests in the build.


## Motivation

These tests were introduced by @chrisroos & @floehopper in 2015 to reduce the risk of doing large-scale refactoring within the application. In particular, they wanted to make a substantial change to the way that landing, question & outcome pages were rendered. The vast majority of the integration tests did not (and still don't) render these pages and in general test coverage was very patchy. The regression tests were created to fulfil this requirement.

The plan is to [refactor all the existing flows](refactoring.md) to separate the "model", "view" & "controller" concerns and use a [new testing approach](testing.md) which would render the regression tests obsolete.

The regression tests are quite brittle and some of them take a long time to run which can make development a bit painful. However, they are serving an important purpose and we hope to remove them as soon as possible.

## Coverage

At the time of their introduction, Rcov was used to pick a minimal combinations of responses which exercised as much of the logic in the flow as possible. However, coverage is not exhaustive, particularly in flows which use country drop-downs (e.g. Marriage Abroad), or numeric inputs.

Thus it is possible to make a change to the behaviour of a flow and for the regression tests to continue to pass, because you have affected a path that is not covered by the regression tests. In this case, if the new behaviour is significantly different from anything already covered, you should consider adding test coverage for the new behaviour.

However, this new test coverage doesn't have to be at the regression test level, it might be sufficient to do it at the integration test or unit test level.

## Regression test files

### Questions & responses file

This file stores the responses to be used for each question when running the tests. The filenames are of the form: `test/data/<smart-answer-flow-name>-questions-and-responses.yml`.

The `script/generate-questions-and-responses-for-smart-answer.rb` script can be used to generate this file, but it requires manual intervention for questions which don't have a limited/known set of options (i.e. questions other than multi-choice/checkbox questions).

You *will* need to update it if you:

  * add a question
  * remove a question
  * rename a question key
  * remove an option from a multi-choice/checkbox question (if being exercised)

You *might* want to consider updating it (for [coverage purposes](#coverage)) if you:

  * add an option to a multi-choice/checkbox question
  * change the routing logic i.e. the logic deciding which questions are asked in what order

### Responses & expected results file

This file is effectively a cache of the nodes reached by particular combinations of responses. This is an optimisation which makes running the regression tests faster when this cached data does not need to change.

You *will* need to update it if you:

* change the "questions & responses" file
* change the routing logic

The filenames are of the form: `test/data/<smart-answer-flow-name>-responses-and-expected-results.yml`

The `script/generate-responses-and-expected-results-for-smart-answer.rb` script should always be used to generate this file.

Usage:
```shell
bundle exec rails r script/generate-responses-and-expected-results-for-smart-answer.rb <smart-answer-flow-name>
```

For example to regenerate `test/data/marriage-abroad-responses-and-expected-results.yml`:

```shell
bundle exec rails r script/generate-responses-and-expected-results-for-smart-answer.rb marriage-abroad
```

### Artefact files

Each of these files captures the content of the page reached by a particular combination of responses. The path to the artefact file represents the responses used to reach that page closely resembles the relevant URL path (although the initial `/y` is not included).

Landing pages and outcome pages are stored in their Govspeak form, i.e. before they are converted into HTML. Question pages are stored in their HTML form.

* `test/artefacts/<smart-answer-flow-name>/<smart-answer-flow-name>.txt` - rendered Govspeak for landing page
* `test/artefacts/<smart-answer-flow-name>/<responses-sequence>.html` - rendered HTML for question page
* `test/artefacts/<smart-answer-flow-name>/<responses-sequence>.txt` - rendered Govspeak for outcome pages

When you run the regression tests, it deletes all the existing artefacts, regenerates them using the responses & expected results file, and then compares the newly generated artefacts with the *version stored in the git repository*. If they differ at all the test will fail. Note that this means you must *commit* any expected changes to the artefacts before running the tests.

The regression tests will also fail if not all nodes are exercised by the test data.

You will need to update the artefacts if you:

  * change the "responses & expected results" file
  * change anything that will affect the content displayed in landing, question, or outcome pages

If there's a difference in the artefacts, you should carefully review the changes to the newly generated artefacts to make sure they all relate to the changes you have made before you commit them.

## Running regression tests

You can run just the regression tests (i.e. not the main test suite) with the following command:

```bash
$ RUN_REGRESSION_TESTS=true ruby test/regression/smart_answers_regression_test.rb
```

You can run just the regression tests for a single flow using this command:

```bash
$ RUN_REGRESSION_TESTS=<smart-answer-flow-name> ruby test/regression/smart_answers_regression_test.rb
```

Note that the `RUN_REGRESSION_TESTS` environment variable can also be used in conjunction with the rake `test` task if you want to force regression tests to run as part of the standard build.

By default most of the assertions in the regression tests are combined into a single assertion at the end. If you want the regression tests to fail fast then set `ASSERT_EACH_ARTEFACT=true`. However, you should note that this more than doubles the time it takes them to run.

Running the test regenerates a set of HTML/Govspeak files in `test/artefacts` based on the files in `test/data` and these are compared against the files in same directory in the git repository i.e. the *committed* versions of the files.

## Making changes

When making changes to a Smart Answer you will probably need to make changes to the regression test files for that flow. The following table aims to give some examples of which files are likely to need updating in a number of scenarios:

| Scope of changes | Questions & responses | Responses & expected results | Artefacts |
|------------------|-----------------------|------------------------------|-----------|
| Internal refactoring | No | No | No |
| Content change | No | No | Yes |
| Routing logic change | No | Yes | Yes |
| Question added/removed | Yes | Yes | Yes |

## Structuring commits

As explained in [this article][1] (referenced by the [pull request styleguide][2]), it's good practice to make your commits atomic. This means that the code should all be in a consistent state and all the tests should be passing for every commit.

Thus ideally we would include the changes to the regression test files in the *same commit* as the corresponding changes to the application code. However, there are some other considerations (outlined below) which mean that we don't always follow this ideal approach.

Note that even when following one of these approaches, it's always important to carefully review the changes to the artefacts and to explain them in the relevant commit note as per the [Artefact changes](#artefact-changes) section below.

### Large diffs

We should always be thinking about making it easy for someone to review our changes in a pull request. Reviewing a diff with a lot of changes can be very hard, so this should be avoided. Having said that, just because a diff is large doesn't always mean it will be hard to review e.g. if the diff is just full of a single change repeated many times, this can be easily explained in the commit note.

If you think the diff is too large, the first thing to consider is whether you can split your changes to the application into multiple smaller (but still atomic) commits. That way you can reduce the number of changes to the artefacts needed in each commit.

If it's really not possible to split up the changes to the application code any further, it may be worth making the changes to the artefacts in a separate commit.

### Slow tests

The regression tests for some flows (e.g. Marriage Abroad) are very slow and it is prohibitively time-consuming to run them after each small change to the application code. In these cases, we sometimes batch up the changes to the artefacts into one or more separate commits.

We are investigating ways to speed up running the regression tests, so this problem may go away.

You should only use this approach if the regression tests for the relevant flow really do take a long time. You should *not* adopt this as your default approach.

## Artefact changes

If you have generated some changes to the regression test artefacts, it's important to *review* the changes before committing them to make sure that they are as you would expect. When you commit the changes, you should explain in the commit note why the various artefacts have changed in the way they have.

Coming up with such an explanation can be quite challenging and is another good reason to keep your commits as small as possible (see above). However, sometimes it's hard to avoid larger commits and in these cases there are a few tactics which can help:

### Preparatory commits

The idea is to make preparatory commits which add/remove/rename regression test artefacts in anticipation of what you expect to happen to them. We usually do this with the standard Unix commands, e.g. `cp`, `mv` & `rm`. This is particularly useful where the paths through the flow have changed. Here are a couple examples:

* [PR #2035](https://github.com/alphagov/smart-answers/pull/2035) e.g. [Update pay-leave-for-parents artefacts: Rename no/2012-2-1 directory](https://github.com/alphagov/smart-answers/commit/5725e068a7a4e655a167f7f8eae0078f573557b8)
* [PR #2051](https://github.com/alphagov/smart-answers/pull/2051) e.g. [Rename regression test artefacts for SSP](https://github.com/alphagov/smart-answers/commit/3374db3cb20644a0b9ee4542d9b0964760922711)

### Programmatic diff checking

The idea is to use Unix command line tools (e.g. `grep`, `find`, `diff`, etc) to come up with automated ways to check that the changes to the artefacts are as you would expect. This is particularly useful when a lot of artefacts are affected by the same content change(s). It's useful to include the commands which you executed (and their output) in the commit note. Here are a couple of examples:

* [PR #2161](https://github.com/alphagov/smart-answers/pull/2161) e.g. [Regenerate test artefacts for am-i-getting-minimum-wage](https://github.com/alphagov/smart-answers/commit/f92e4e0033bbb1915f57e33cf749834c0d843987)
* [PR #2181](https://github.com/alphagov/smart-answers/pull/2181) e.g. [Update regression test artefacts for question pages](https://github.com/alphagov/smart-answers/commit/023a64c4c288194d4a5f94a68e824cea8b272816)

### Unix tree view

The Unix `tree` command can be used to generate an ASCII-art view of the relevant artefacts directory or sub-directory. You can generate this view before and after a change and include them in the commit note with annotations explaining what has changed and why. Here is an example:

* [PR #2529](https://github.com/alphagov/smart-answers/pull/2529) e.g. [Update regression test responses, expected results & artefacts](https://github.com/alphagov/smart-answers/commit/b225746fd044c5699075778fc1b507662c881df5)

[1]: http://www.annashipman.co.uk/jfdi/good-pull-requests.html
[2]: https://github.com/alphagov/styleguides/blob/master/pull-requests.md
