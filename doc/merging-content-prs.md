## Merging a pull request from the Content Team

### Introduction

Members of the Content Team do not have permission to contribute directly to the canonical repository, so when they want to make a change, they create a pull request using a fork of the repository. Also since they don't usually have a Ruby environment setup on their local machine, they will not be able to update
files relating to the regression tests e.g. file checksums, Govspeak artefacts, etc. See documentation about [adding regression tests](adding-new-regression-tests.md) for more information.

## Instructions

1. Check out the branch from the forked repo onto your local machine. Note that `<github-username>` refers to the owner

```bash
$ git remote add <owner-of-forked-repo> git@github.com:<owner-of-forked-repo>/smart-answers.git
$ git fetch <owner-of-forked-repo>
$ git co -b <branch-on-local-repo> <owner-of-forked-repo>/<branch-on-forked-repo>
```

2. Review the changes in the commit(s)
3. Remove any trailing whitespace
4. Run the following command to re-generate the Govspeak artefacts (in `test/artefacts/<smart-answer-flow-name>`) for the regression tests:

```bash
$ RUN_REGRESSION_TESTS=<smart-answer-flow-name> ruby test/regression/smart_answers_regression_test.rb
```

5. Review the changes to the Govspeak artefacts to check they are as expected
6. Run the following command to update the checksums for the smart answer:

```bash
$ rails r script/generate-checksums-for-smart-answer.rb <smart-answer-flow-name>
```

7. Run the main test suite

```bash
$ rake
```

8. Stage the changed files & add a new commit or amend the commit

```bash
$ git add .
$ git commit # ok to amend commit if only one commit in PR
```

9. Run the regression test for the smart answer (now that Govspeak artefacts & file checksums have been updated)

```bash
$ RUN_REGRESSION_TESTS=<smart-answer-flow-name> ruby test/regression/smart_answers_regression_test.rb
```

10. Push the branch to GitHub and submit a new pull request so that people have a chance to review the changes and a Continuous Integration build is triggered. Close the original pull request.

```bash
$ git push origin <branch-on-local-repo>
```

See documentation on [regression tests](regression-tests.md) for further details.
