# Deploying

## Preview

This happens automatically when the main CI build passes.

### Manually

If you have sufficient permissions, you can use the [Preview Deploy Jenkins project](https://deploy.preview.alphagov.co.uk/job/Preview_Deploy/). Click the "Build with Parameters" link and enter "release" as the "TAG".

If you do not have sufficient permissions, you can either kick the main CI build in Jenkins or commit & push something to the `master` branch.

## Production

These are usually done with a Smart Answers developer sitting with someone from 2nd-line Support. You need to prepare and book a production deployment as folows:

### Create the Release in GitHub

#### 1. Find the latest release

Open the [list of releases][smart-answers-releases] and make a note of the name of the most recent release (referred to as `$RELEASE-TAG` below).

##### NOTE. Jenkins and releases

After a successful build of the master branch on Jenkins:

* Jenkins updates the `release` branch to point at HEAD
* Jenkins creates a `release_nnnn` tag pointing at HEAD


#### 2. Review the changes waiting to be deployed to production

Open "https://github.com/alphagov/smart-answers/compare/deployed-to-production...$RELEASE-TAG".

Open each of the merged Pull Requests that are waiting to be deployed and ensure that the description contains details of the expected changes.


#### 3. Update the latest release on GitHub

Open "https://github.com/alphagov/smart-answers/releases/tag/$RELEASE-TAG".

Click "Edit release".

Leave the "Release title" blank.

Set the description to:

```
## All included PRs

TODO: List each of the Pull Requests included in the release, for example:

* PR https://github.com/alphagov/smart-answers/pull/nnn - <title-of-pull-request>

## PRs to check post-deployment

TODO: List each of the Pull Requests that contain user facing changes here, for example:

* PR https://github.com/alphagov/smart-answers/pull/nnn - <title-of-pull-request>
```

### Create the deployment calendar event

1. Add an event to the "GOVUK Release Calender"

  * Title: "Smart Answers (2nd line required)"
  * Time: <The time you'd like to deploy>
  * Duration: 30 minutes
  * Description: https://github.com/alphagov/smart-answers/releases/tag/$RELEASE-TAG

[smart-answers-releases]: https://github.com/alphagov/smart-answers/releases
