# Rubocop

We're using the govuk-lint Gem to include Rubocop and the GOV.UK styleguide rules in the project.

### Jenkins

We run Rubocop as part of the test suite executed on Jenkins (see jenkins.sh). Rubocop only tests for violations in files introduced in the branch being tested. This should prevent us from introducing new violations without us having to first fix all existing violations.

### Running locally

Testing for violations in the entire codebase:

```bash
$ govuk-lint-ruby
```

Testing for violations in code committed locally that's not present in origin/master (useful to check code committed in a local branch):

```bash
$ govuk-lint-ruby --diff
```

Testing for violations in code staged and committed locally that's not present in origin/master:

```bash
$ govuk-lint-ruby --diff --cached
```

NOTE. This is mostly useful for Jenkins as we first merge, but don't commit, changes from master before running the test suite.
