Smart Answers
=============

> Smart answers are a great tool for content designers to present complex information in a quick and simple way. Defining what they are – decision trees? calculators? tools? is immaterial – what they do is provide a reusable technical framework to build a quick and simple answer to a complex question.

Read more in [a blog post](https://gds.blog.gov.uk/2012/02/16/smart-answers-are-smart/).

Have a look at
[`test/unit/flow_test.rb`](test/unit/flow_test.rb) for example usage.

This application supports two styles of writing and executing smart answers:

**Ruby and YAML-based smart answer flows**

For more information, please go to the [Ruby/YAML SmartAnswer README](lib/smart_answer_flows/README.md)

**Smartdown-based smart answer flows**

For more information, please go to the [Smartdown SmartAnswer README](lib/smartdown_flows/README.md)

**Switching from one style to another**

Smart answers are by default expected to be in Ruby/YAML style.
To transition a smart answer from Ruby/YML to Smartdown style, register it in the smartdown registry (`lib/smartdown/registry.rb`).

**Debugging current state**

If you have a URL of a Smart answer and want to debug the state of it i.e. to see PhraseList keys, saved inputs, the outcome name, append `debug=1` query parameter to the URL in development mode. This will render debug information on the Smart answer page.

**Visualising a flow**

To see a visualisation of a smart answer flow, append `/visualise` to the root of a smartanswer URL e.g. `http://smartanswers.dev.gov.uk/<my-flow>/visualise/`

Installing and running
------------

NB: this assumes you are running on the GOV.UK virtual machine, not your host.

```bash
  ./install # git fetch from each dependency dir and bundle install
```

Run using bowler on VM from cd /var/govuk/development:
```
bowl smartanswers
```

Viewing a Smart Answer
------------

To view a smart answer locally if running using bowler http://smartanswers.dev.gov.uk/register-a-birth

Testing
------------
Run unit tests by executing the following:

    bundle exec rake

** Fixtures **

If you need to add a new worldwide organisations fixture find [it here](https://www.gov.uk/government/world/organisations) by the country name or its capital city, navigate to `<found_url>.json`, most likely it will be of the following format `https://www.gov.uk/api/world/organisations/british-[embassy|high-commission]-<capital city>`, copy over the JSON to `test/fixtures/worldwide/<country>_organisations.json` and change it to reflect the expected format based on other examples in the directory.

### Testing Smartdown flows

Smartdown flows are tested using [scenarios][smartdown-scenarios] in the flow directories.

Test all Smartdown flows by running:

    bundle exec ruby -Itest test/unit/smartdown_content/smartdown_scenarios_test.rb

Test a single Smartdown flow by running:

     SMARTDOWN_FLOW_TO_TEST=<name-of-smartdown-flow> \
     bundle exec ruby -Itest test/unit/smartdown_content/smartdown_scenarios_test.rb

[smartdown-scenarios]: https://github.com/alphagov/smartdown/blob/master/doc/scenarios.md

Issues/todos
------------

Please see the [github issues](https://github.com/alphagov/smart-answers/issues) page.

Making bigger changes
------

When making bigger changes that need to be tested before they go live it is best to release them as a draft first. There is a rake task for creating a draft flow `rake version:v2[flow]`. This is not ideal, but it allows to check the changes in the UI in the development and preview environments without affecting the production environment.

Once reviewed, the draft can be published by running `rake version:publish[flow]`. This merges V2 changes into the original files. Take a look at the [rake task](https://github.com/alphagov/smart-answers/blob/master/lib/tasks/version.rake) to see the details. If you used any other V2 files that are not covered by the rake task, make sure to process them manually.

**Commiting V2 -> V1 changes**

To help developers track changes in files easily, it is best if you commit V2 files' removal in one commit, then commit the modifications to the original files. This creates an easy to browse diff of all the changes being published. Write a descriptive message for the second commit, as this is what the other developers will see in the file history.


## Detailed documentation

- [How to archive a Smart Answer](doc/archiving.md)

## Deploying to Heroku

    heroku apps:create

    heroku config:set GOVUK_APP_DOMAIN=preview.alphagov.co.uk
    heroku config:set PLEK_SERVICE_CONTENTAPI_URI=https://www.gov.uk/api
    heroku config:set PLEK_SERVICE_STATIC_URI=https://assets-origin.preview.alphagov.co.uk
    heroku config:set RUNNING_ON_HEROKU=true

    git push heroku <your-local-branch>:master

    # *NOTE.* You'll need to add the path to a Smart Answer, e.g. /marriage-abroad
    heroku apps:open
