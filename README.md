# Smart Answers

A tool for content designers to present complex information as a flow of questions, leading to an outcome. While the app is mostly self-contained, some Smart Answers use [Imminence](https://github.com/alphagov/imminence) for Post Code lookup, and [Whitehall](https://github.com/alphagov/whitehall) to get data on countries and worldwide organisations.

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

### Smart Answer design

* [File structure](docs/design/file-structure.md)
* [Flow definition](docs/design/flow-definition.md)
* [Question types](docs/design/question-types.md)
* [Next node rules](docs/design/next-node-rules.md)
* [Storing data](docs/design/storing-data.md)
* [ERB templates](docs/design/erb-templates.md)
  * [Landing page template](docs/design/erb-templates/landing-page-template.md)
  * [Question templates](docs/design/erb-templates/question-templates.md)
  * [Outcome templates](docs/design/erb-templates/outcome-templates.md)

### Smart Answer tasks

* [Development principles](docs/tasks/development-principles.md)
* [Deploying changes for fact-check](docs/tasks/fact-check.md)
* [Creating a new Smart Answer](docs/tasks/creating-a-new-smart-answer.md)
* [Publishing a Smart Answer](docs/tasks/publishing.md)

Further guidance is available in [`docs/tasks`](docs/tasks).

### Smart Answers app development

* [Testing](docs/smart-answers-app-development/testing.md)

### Further documentation

- [Debugging Smart Answers](docs/debugging)
- [Historical background: blog post on Smart Answers](https://gds.blog.gov.uk/2012/02/16/smart-answers-are-smart/).

## Licence

[MIT License](./LICENSE.md)
