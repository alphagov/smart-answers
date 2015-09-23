# Smart Answers

## Introduction

> Smart answers are a great tool for content designers to present complex information in a quick and simple way. Defining what they are – decision trees? calculators? tools? is immaterial – what they do is provide a reusable technical framework to build a quick and simple answer to a complex question.

Read more in [a blog post](https://gds.blog.gov.uk/2012/02/16/smart-answers-are-smart/).

Have a look at
[`test/unit/flow_test.rb`](test/unit/flow_test.rb) for example usage.

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

## Testing

Run all tests by executing the following:

    bundle exec rake

## Table of Contents

* Types of Smart Answer
  * [Ruby](doc/smart-answer-flows.md)
  * [Smartdown](doc/smartdown-flows.md) (__DEPRECATED__)
* Process
  * [Archiving a Smart Answer](doc/archiving.md)
  * [Deploying changes for Factcheck](doc/factcheck.md)
  * [Merging pull requests from the content team](doc/merging-content-prs.md)
* Development
  * Adding [content-ids](doc/content-ids.md) to Smart Answers.
  * [Issues and Todo](https://github.com/alphagov/smart-answers/issues)
  * [Rubocop](doc/rubocop.md)
  * [Updating worldwide fixture data](doc/updating-worldwide-fixture-data.md)
* Debugging
  * [Viewing landing pages and outcomes as Govspeak](doc/viewing-templates-as-govspeak.md)
  * [Viewing state of a Smart Answer](doc/viewing-state.md)
  * [Visualising flows](doc/visualising-flows.md)
