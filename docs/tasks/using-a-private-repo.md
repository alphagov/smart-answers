# Using a private repo

Some changes are sensitive and should not be applied to the public repository until they are ready to go live. Whilst such changes are being developed and reviewed, they should be made to a private clone of the Smart Answers repository.

## Workflow

### Creating a private repository

The first step is to create a private fork of the Smart Answers repository, by following the first seven steps of [Creating a private fork](https://docs.publishing.service.gov.uk/manual/make-github-repo-private.html#creating-a-private-fork). Optionally, you can also copy the main branch protection settings from the public Smart Answers repository by choosing to create a "classic" branch protection rule (step 11 of the instructions); however, this will make it harder to keep the main branch of the private repo up-to-date with the main branch of the public repo, should you wish to do so.

### Setting up the private local repository

Once the fork is ready (the import at step 2 can take a 10–15 minutes), clone the private repository locally, and follow the below steps:

- Add a remote link to the public repository:
    ````shell
    git remote add public [public repo link]
    ````
    [public repo link] should be replaced with the link you would use to clone the public repository.
- Create a local branch for development work.

### Implement the changes

Carry out the necessary work on your private local branch. We don't have Heroku app deployments set up, so we don't have a preview link to share with content designers for fact-check, so instead take appropriate screenshots, zip them up and attach to the Trello card.

You can also create a PR in the private repository on GitHub for review by another developer, but you don't need to actually merge this PR once it's approved—leave the branch in place so that it can be used to open a PR on the public repository.

### Create a PR on the public repository

Once it is time to make the changes public, you can create a PR on the public repository.

1. In the **public** local repository, add a remote link to the private repository:
    ````shell
    git remote add private [private repo link]
    ````
    [private repo link] should be replaced with the link you would use to clone the private repository.
2. Fetch the changes from the private repository:
    ````shell
    git fetch private
    ````
3. Checkout the branch from the private repository:
    ````shell
    git checkout private/[branch name]
    git checkout -b [branch name]
    ````
4. Rebase the branch onto the main branch of the public repository:
    ````shell
    git rebase origin/main
    ````
5. Push the changes to the public repository on GitHub:
    ````shell
    git push -u origin head
    ````
6. Raise the PR on the public repository on GitHub as usual.

### Cleanup

- Delete the private repository remote from your public local repository:
    ````shell
    git remote remove private
    ````
- Archive the private repository on GitHub.
