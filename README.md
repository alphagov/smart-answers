Smart Answers
=============

Toolkit for building smart answers. Have a look at
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

Issues/todos
------------

Please see the [github issues](https://github.com/alphagov/smart-answers/issues) page.

Drafts
------

When changes need to be tested by third parties it is best to release them as a draft. There is a rake task for creating a draft flow `rake version:v2[flow]`. Once ready, the draft can be published by running `rake version:publish[flow]`
