# Smart Answers

## Introduction

> Smart answers are a great tool for content designers to present complex information in a quick and simple way. Defining what they are – decision trees? calculators? tools? is immaterial – what they do is provide a reusable technical framework to build a quick and simple answer to a complex question.

Read more in [a blog post](https://gds.blog.gov.uk/2012/02/16/smart-answers-are-smart/).

Have a look at
[`test/unit/flow_test.rb`](test/unit/flow_test.rb) for example usage.

This application supports two styles of writing and executing smart answers:

### Ruby smart answer flows

For more information, please go to the [Ruby SmartAnswer README](doc/smart-answer-flows.md)

### DEPRECATED: Smartdown-based smart answer flows

For more information, please go to the [Smartdown SmartAnswer README](doc/smartdown-flows.md)

## Developing

### Installing and running

NB: this assumes you are running on the GOV.UK virtual machine, not your host.

```bash
  ./install # git fetch from each dependency dir and bundle install
```

Run using bowler on VM from cd /var/govuk/development:
```
bowl smartanswers
```

### Viewing a Smart Answer

To view a smart answer locally if running using bowler http://smartanswers.dev.gov.uk/register-a-birth

### Debugging current state

If you have a URL of a Smart answer and want to debug the state of it i.e. to see PhraseList keys, saved inputs, the outcome name, append `debug=1` query parameter to the URL in development mode. This will render debug information on the Smart answer page.

### Viewing a Smart Answer as Govspeak

Seeing [Govspeak](https://github.com/alphagov/govspeak) markup of Smart Answer pages can be useful to content designers when preparing content change requests or developers inspecting generated Govspeak that later gets translated to HTML. This feature can be enabled by setting `EXPOSE_GOVSPEAK` to a non-empty value. It can be accessed by appending `.txt` to URLs (currently govspeak is available for landing and outcome pages, but not question pages).

## Testing

Run all tests by executing the following:

    bundle exec rake

## Making bigger changes

When making bigger changes that need to be tested or fact-checked before they are deployed to GOV.UK it is best to deploy the branch with changes to Heroku.

If you open a PR to review those changes, make sure to mention if it's being fact-checked and should not be merged to master until that's done.

### Deploying to Heroku

The 'startup_heroku.sh' shell script will create and configure an app on Heroku, push the __current branch__ and open the marriage-abroad Smart Answer in the browser.

Once deployed you'll need to use the standard `git push` mechanism to deploy your changes.

    ./startup_heroku.sh

## Table of Contents

* Process
  * [Archiving a Smart Answer](doc/archiving.md)
  * [Merging pull requests from the content team](doc/merging-content-prs.md)
* Development
  * Adding [content-ids](doc/content-ids.md) to Smart Answers.
  * [Issues and Todo](https://github.com/alphagov/smart-answers/issues)
  * [Rubocop](doc/rubocop.md)
  * [Updating worldwide fixture data](doc/updating-worldwide-fixture-data.md)
  * [Visualising flows](doc/visualising-flows.md)
