# Smart Answers

A tool for content designers to present complex information as a flow of questions, leading to an outcome. While the app is mostly self-contained, some Smart Answers use [Whitehall](https://github.com/alphagov/whitehall) to get data on countries and worldwide organisations.

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

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) or the local `startup.sh --live` script to run the app. Read the [guidance on local frontend development](https://docs.publishing.service.gov.uk/manual/local-frontend-development.html) to find out more about each approach, before you get started.

If working on a smart answer that makes use of an API, use the local `startup.sh --live` script to run the app instead of docker.

If you are using GOV.UK Docker, remember to combine it with the commands that follow. See the [GOV.UK Docker usage instructions](https://github.com/alphagov/govuk-docker#usage) for examples.

### Running the test suite

```
bundle exec rake
```

### Troubleshooting
- When running integration tests, if you get `SessionNotCreatedException: Message: session not created: This version of ChromeDriver only supports Chrome version <some version number>` error, then:
  - run `brew install chromedriver` or if you already have the cask, `brew upgrade chromedriver`
  - if that doesn't work, install the correct Chrome driver into `usr/local/bin`
- When running `bundle exec rake`, if you get `rake aborted!
  LoadError: linked to incompatible <some libruby or gem link>`, run `gem pristine --all`


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

### Further documentation

- [Debugging Smart Answers](docs/debugging)
- [Historical background: blog post on Smart Answers](https://gds.blog.gov.uk/2012/02/16/smart-answers-are-smart/).

## Licence

[MIT License](./LICENCE)
