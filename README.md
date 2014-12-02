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

Installing
----------

NB: this assumes you are running on the GOV.UK virtual machine, not your host.

```bash
  ./install # git fetch from each dependency dir and bundle install
```

Testing
------------
Run unit tests by executing the following:

    bundle exec rake

Issues/todos
------------

Please see the [github issues](https://github.com/alphagov/smart-answers/issues) page.
