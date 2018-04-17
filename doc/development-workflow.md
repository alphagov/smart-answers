# Development workflow

## Making a content change

If you make a content change, you will need to update the regression test checksum file, and possibly the artefact files as well. There isn't one "correct" way to organise your commits in a pull request. However, as a starting point, here are the steps you might use to implement a simple content change:

1. Make the change to the relevant template file.

2. [Run the regression tests](regression-tests.md#running-regression-tests) thus regenerating the artefacts.

3. Review the changes to the [artefacts](regression-tests.md#artefact-files) and check they are as you expect.

4. If artefact changes are as expected, [regenerate the checksums](regression-tests.md#checksum-file).

5. Commit all the changes with a suitable explanation in the commit note.

6. Run the regression tests and check they all pass.

## Creating a Pull Request

As the Pull Request author:

1. Open a PR with the changes you want to merge.

2. Add the appropriate label(s):

  * Documentation - if this change only affects docs within the app.
  * Refactoring - if this change doesn't affect the external behaviour of the app.
  * Spike - if this is an exploratory change to see whether a certain approach works.
  * Don't merge - to make it very clear that this shouldn't be merged.
  * Needs factcheck - if this requires fact-checking after code review.

3. Add the "Ready for code review" label.

4. Move the associated Trello card from "In progress" to "Code review".

5. Add the PR link to the Trello card as an attachment.

## Reviewing a Pull Request

As the Pull Request reviewer:

1. Assign yourself to the Pull Request.

2. Add the "Ready for code review" label to allow people to see at a glance that the PR is being reviewed.

3. Review the Pull Request.

4. Add a comment to say that the PR looks good if/when you're happy with it.

5. Add the "Passed code review" label to allow people to see at a glance that the PR has been reviewed.

## Fact-checking a Pull Request (Optional)

As the Pull Request author:

1. Replace the "Needs factcheck" label with "Waiting on factcheck".

2. Move the associated Trello card from "Code review" to "Fact check".

3. Add a comment to the associated Trello card to let the relevant people know it's ready to check.

4. If/when the change passes factcheck, replace the "Waiting on factcheck" label with the "Passed factcheck" label.

## Merging a Pull Request

As the Pull Request author:

1. Rebase the branch on master.

2. Force push the branch to GitHub.

3. Click "Merge pull request".

4. Click "Delete branch".
