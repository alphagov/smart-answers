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

### Running the application

See:

* [Developing using the GDS development virtual machine](doc/developing-using-vm.md)
* [Developing without using the development VM](doc/developing-without-vm.md)

### Running the test suite

    $ bundle exec rake

### Smart Answers

* [File structure](doc/file-structure.md)
* [Flow definition](doc/flow-definition.md)
* [Question types](doc/question-types.md)
* [Next node rules](doc/next-node-rules.md)
* [Storing data](doc/storing-data.md)
* [ERB templates](doc/erb-templates.md)
  * [Landing page template](doc/landing-page-template.md)
  * [Question templates](doc/question-templates.md)
  * [Outcome templates](doc/outcome-templates.md)

### Smart Answer flow development

* [Development principles](doc/development-principles.md)
* [Deploying changes for Factcheck](doc/factcheck.md)
* [Merging pull requests from the content team](doc/merging-content-prs.md)
* [Refactoring existing Smart Answers](doc/refactoring.md)
* Adding [content-ids](doc/content-ids.md) to Smart Answers
* [Creating a new Smart Answer](doc/creating-a-new-smart-answer.md)
* [Archiving a Smart Answer](doc/archiving.md)
* [Updating worldwide fixture data](doc/updating-worldwide-fixture-data.md)

### Smart Answers app development

* [Common errors you might run into during development](doc/common-errors.md)
* [Environments](doc/environments.md)
* [Continuous integration](doc/continuous-integration.md)
* [Describing pull requests](doc/pull-requests.md)
* [Deploying](doc/deploying.md)
* [Handling exceptions with Errbit](doc/errbit.md)
* [Rubocop](doc/rubocop.md)
* [Testing](doc/testing.md)
* [Issues and Todo](https://trello.com/b/7HgyU4hy/smart-answers-tasks)

### Debugging

* [Viewing landing pages and outcomes as Govspeak](doc/viewing-templates-as-govspeak.md)
* [Viewing state of a Smart Answer](doc/viewing-state.md)
* [Visualising flows](doc/visualising-flows.md)

## Licence

[MIT License](./LICENSE.md)
