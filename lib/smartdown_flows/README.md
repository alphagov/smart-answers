Smartdown Smart Answers
=============

Smartdown flows are stored in `lib/smartdown_flows`.

The code responsible for executing the flow of those questions is in the [smartdown gem](https://github.com/alphagov/smartdown).

##Smartdown scenarios check

A smartdown content test has been created to run through the test scenarios on all Smartdown questions and ensure they still pass.
To run only that test, use the command:

```rake smartdown_scenarios:run["name_of_smartdown_flow"]```

For every smartdown flow, this goes through all the scenarios defined for them and:
- checks each set of questions has been asked in the right order
- checks the right outcome has been reached given the answers

##Register a birth

Five tools specific to the register a birth tool were developed to facilitate question transition.

###Scenario generation

```rake register_a_birth_transition:generate_scenarios```

This task runs through the smartdown flow and writes to the `smartdown_data/scenarios/register-a-birth-transition/generated_scenarios.txt` file all possible answers that could be used to go through the flow based on the combinations hardcoded in that task, and writes scenarios

###Combination generation

```rake register_a_birth_transition:generate_combinations```

This task runs through the smartdown flow and writes to files in the `smartdown_data/combinations/register-a-birth-transition` folder all possible answers that could be used to go through the flow based on the combinations hardcoded in that task.

###Comparison tools

Three comparison tools have been created for register a birth. Combinations of answers are used both in the `register-a-birth-transition` Smartdown flow and the `register-a-birth` smart-answer flow, and the HTML output is compared. If any difference is spotted, an error is raised, and its URL is written to text files in the `smartdown_data/errors/register-a-birth-transition` folder.

The difference between these comparison tools lies in what combinations of answers are used.

1. Compare to smart-answers from scenarios

```rake register_a_birth_transition:compare_to_smartanswer_from_scenarios```

The answers in the register-a-birth-transition scenarios are used to run the comparison.

2. Compare to smart-answers from combinations

```rake register_a_birth_transition:compare_to_smartanswer_from_combinations```

The answers in the register-a-birth-transition combinations are used to run the comparison.

3. Compare to smart-answers from errors

```rake register_a_birth_transition:compare_to_smartanswer_from_errors```

The answers listed in the `smartdown_data/errors/register-a-birth-transition` are used to run the comparison.

##Pay and leave for parents

Two tools specific to the pay and leave for parents tool were developed to facilitate question writing and fact-checking.

###Outcome generation

```rake pay_leave_for_parents:generate_outcomes```

This command goes through all the outcomes listed in the Pay and leave for parents questions and generates outcome files that
are prepopulated with snippets.
For the pay and leave for parents, we use the convention of naming each outcome as an `_`-separated string of all snippets to be listed for that outcome.

###Factcheck table generation

```rake pay_leave_for_parents:generate_factcheck```

####Output of the tool

This rake task builds four markdown documents and saves them to the ```smartdown_data/factcheck/pay_leave_for_parents``` folder.
Those four markdown documents summarise the question outcomes for:
* Birth cases before 05/04/2015
* Birth cases after 05/04/2015

Each markdown document is a table summarising the answers given to each question and listing what types of maternity,
paternity, adoption, shared parental leave and pay the user(s) is/are eligible for given their answer.

####How possible combinations are generated

We have chosen for each question in the pay and leave for parents a selection of answers that can affect the outcome of the tool.
This is not an exhaustive list of possible answers. As the tool evolves and more legal rules are added, **possible answers
that can affect the outcome of the flow should be added to the combinations to have an accurate and complete factcheck table**.

### Smartdown Plugins

Each smartdown flow can have an optional smartdown plugin. These plugins provide helper methods that are used in the generation of smartdown questions and answers. Smartdown plugins are located within lib/smartdown_plugins/*flow_name*/
Currently there are two types of smartdown plugins. render_time.rb and build_time.rb.

lib/smartdown_plugins/*flow_name*/
  - render_time.rb
  - build_time.rb

####Shared Plugins
smartdown plugins also have access to a communal set of shared functions. These shared functions are located within lib/smartdown_plugins/shared/. To use a shared plugin, extend it in your flow-specific plugin: like so

````
module SmartdownPlugins
  module ExampleFlowPlugin
    extend SharedPlugin
    .
    .
    .
  end
end
````

####Render Time

Render time smartdown plugins are intended to be used to store functions that will be passed a users answers to question as the arguments. You could use them to render templates, perform calculations or make external HTTP requests to a data source.

####Build Time

Build time smartdown plugins contain methods that are available to smartdown in the parsing/building process. This means that they do not take any arguments - ie. they are just used as
a way of injecting data to the build step, often in the form of a ruby hash.

####Data Partials

Will render an erb template that is located within lib/smart_answer_flows/data_partials. It accepts locals that are passed to the template.

Example usage:

````
require 'uri'

module FlowIdentifierName
  extend DataPartial

  def self.data_embassy(country_name)
    location = open("http://example.com/countries/#{country_name}.json")
    render 'data_partial_name', locals: {location: location}
  end

end
````
