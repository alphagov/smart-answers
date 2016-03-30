# Rubocop

We're using the govuk-lint Gem to include Rubocop and the GOV.UK styleguide rules in the project.

### Jenkins

We run Rubocop as part of the test suite executed on Jenkins (see jenkins.sh). We've generated a project-specific `.rubocop_todo.yml` file using `govuk-lint-ruby --auto-gen-config --exclude-limit 99999` which [excludes existing violations on a per-cop basis][1]. The limit was set to `99999` to minimise the number of cops that are disabled entirely - most are only disabled for a specific set of files.

The generated `.rubocop_todo.yml` file is included into the configuration via a local `.rubocop.yml` file using an `inherit_from` key. This means that the exclusions in `.rubocop_todo.yml` are used for all `govuk-lint-ruby` commands by default.

Using this approach should prevent us from introducing new violations into the project without needing to fix all the existing violations first. However, in the long run, the idea is for us to gradually remove these exclusions to bring the project fully in line with the default `govuk-lint-ruby` configuration.

Note that as per the header comment in  `.rubocop_todo.yml`, changes in the inspected code, or installation of new versions of RuboCop, may require `.rubocop_todo.yml` to be generated again.

### Running locally

Testing for violations in the entire codebase (used by `jenkins.sh`):

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

[1]: https://github.com/bbatsov/rubocop/blob/master/README.md#automatically-generated-configuration
