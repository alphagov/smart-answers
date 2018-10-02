## Merging a pull request from the Content Team

### Introduction

Most members of the Content Team do not have permission to contribute directly to the canonical repository, so when they want to make a change, they often create a pull request using a fork of the repository. Also since they don't usually have a Ruby environment setup on their local machine, they will not be able to update
files relating to the regression tests e.g. file checksums, Govspeak artefacts, etc. See documentation about [regression tests](../smart-answers-app-development/regression-tests.md) for more information.

## Instructions

1. Check out the branch from the forked repo onto your local machine (if they submitted a fork rather than a branch). Note that `<github-username>` refers to the owner

```bash
$ git remote add <owner-of-forked-repo> git@github.com:<owner-of-forked-repo>/smart-answers.git
$ git fetch <owner-of-forked-repo>
$ git co -b <branch-on-local-repo> <owner-of-forked-repo>/<branch-on-forked-repo>
```

2. Review the changes to the Govspeak artefacts to check they are as expected
3. `bundle exec bin/prep_for_pull_request.sh <smart-answer-flow-name>`
