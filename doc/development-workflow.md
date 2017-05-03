# Development workflow

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
