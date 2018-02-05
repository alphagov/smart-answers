# Rubocop

We're using the `govuk-lint` Gem to include Rubocop and the GOV.UK styleguide rules in the project.

### Jenkins

We run `govuk-lint-ruby` as part of the test suite executed on Jenkins. Behind the scenes this runs Rubocop with a set of cops defined in the `govuk-lint` gem.

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
