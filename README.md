# Smart Answers

> Smart answers are a great tool for content designers to present complex information in a quick and simple way. Defining what they are – decision trees? calculators? tools? is immaterial – what they do is provide a reusable technical framework to build a quick and simple answer to a complex question.

Read more in [Lisa Scott's GDS blog post](https://gds.blog.gov.uk/2012/02/16/smart-answers-are-smart/).

## Screenshots

![Student Finance Forms screenshot](./doc/assets/govuk-student-finance-forms.png)

## Live examples

* [Look up Meursing code](https://www.gov.uk/additional-commodity-code)
* [Maternity and paternity calculator for employers](https://www.gov.uk/maternity-paternity-calculator)
* [Towing: licence and age requirements](https://www.gov.uk/towing-rules)

## Nomenclature

* **Smart Answer**: The flow, questions and outcomes.

* **Flow**: Defines the questions, outcomes and the rules for navigating between them.

* **Landing page**: Contains a description of the Smart Answer and the "Start now" button that leads to the first question.

* **Question page**: Contains an individual question that's asked in order to help arrive at at an outcome.

* **Outcome page**: Contains the result of the Smart Answer based on responses to individual questions.

## Technical documentation

This is a Ruby on Rails application that contains:

* A Rails application to serve Smart Answers
* A DSL for creating Smart Answers
* The Smart Answers that appear on GOV.UK

**NOTE.** This application doesn't use a database and as such it [does not include the ActiveRecord Railtie in application.rb](https://github.com/alphagov/smart-answers/blob/4eb1b80a698e6835e745c4ad1954a3892e929b64/config/application.rb#L3).

### Dependencies

* [alphagov/static](https://github.com/alphagov/static): provides static assets (JS/CSS) and the GOV.UK templates.
* [alphagov/imminence](https://github.com/alphagov/imminence): provides post code lookup
* [alphagov/whitehall](https://github.com/alphagov/whitehall): provides country
  lookup; and information about high commisions and embassies
* [nodejs/node](https://github.com/nodejs/node): provides JS runtime for precompiling assets for deployment

### Smart Answers

* [File structure](doc/smart-answers/file-structure.md)
* [Flow definition](doc/smart-answers/flow-definition.md)
* [Question types](doc/smart-answers/question-types.md)
* [Next node rules](doc/smart-answers/next-node-rules.md)
* [Storing data](doc/smart-answers/storing-data.md)
* [ERB templates](doc/smart-answers/erb-templates.md)
  * [Landing page template](doc/smart-answers/erb-templates/landing-page-template.md)
  * [Question templates](doc/smart-answers/erb-templates/question-templates.md)
  * [Outcome templates](doc/smart-answers/erb-templates/outcome-templates.md)

### Smart Answer flow development

* [Development principles](doc/smart-answer-flow-development/development-principles.md)
* [Deploying changes for Factcheck](doc/smart-answer-flow-development/factcheck.md)
* [Flattening outcomes](doc/smart-answer-flow-development/flattening-outcomes.md)
* [Refactoring existing Smart Answers](doc/smart-answer-flow-development/refactoring.md)
* Adding [content-ids](doc/smart-answer-flow-development/content-ids.md) to Smart Answers
* [Creating a new Smart Answer](doc/smart-answer-flow-development/creating-a-new-smart-answer.md)
* [Archiving a Smart Answer](doc/smart-answer-flow-development/archiving.md)
* [Retiring a Smart Answer](doc/smart-answer-flow-development/retiring-a-smart-answer.md)
* [Updating worldwide fixture data](doc/smart-answer-flow-development/updating-worldwide-fixture-data.md)

### Smart Answers app development

* [Common errors you might run into during development](doc/smart-answers-app-development/common-errors.md)
* [Continuous integration](doc/smart-answers-app-development/continuous-integration.md)
* [Testing](doc/smart-answers-app-development/testing.md)

### Changes to the landing page

Changes to landing pages need to be sent to be sent to the `content store` for them to be rendered on the page. The [rake task `publishing_api:publish_all`](https://github.com/alphagov/smart-answers/blob/master/lib/tasks/publishing_api.rake) needs to be run once you have deployed your changes in each environment and can be done in [Jenkins](https://deploy.integration.publishing.service.gov.uk/job/run-rake-task/parambuild/?TARGET_APPLICATION=smartanswers&MACHINE_CLASS=calculators_frontend&RAKE_TASK=publishing_api:publish_all).

### Debugging

* [Custom Google Analytics accounts and Tracking IDs](doc/debugging/custom-google-analytics-tracking-id.md)
* [Viewing landing pages and outcomes as Govspeak](doc/debugging/viewing-templates-as-govspeak.md)
* [Viewing state of a Smart Answer](doc/debugging/viewing-state.md)
* [Visualising flows](doc/debugging/visualising-flows.md)

### Registering on GOV.UK

- `bundle exec rake publishing_api:publish_all` will send smart answers to the publishing-api.

### Search indexing

Content is now indexed automatically via the publishing API

## Licence

[MIT License](./LICENSE.md)
