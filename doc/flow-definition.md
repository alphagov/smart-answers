# The flow definition

The Ruby flow file defines a `Flow` class that contains all the questions, outcomes and rules to control flow between.

The file should be named the same as the path that we want the Smart Answer to be accessible at on gov.uk. For example, if we want the Smart Answer to be accessible at www.gov.uk/example-smart-answer then:

* The flow file should be 'example-smart-answer.rb'
* The flow class should be `ExampleSmartAnswerFlow`
* The flow name should be 'example-smart-answer'

The `Flow` class contains a single `#define` method that defines the questions (see "Question types" below), rules (see "Defining next node rules" below) and outcomes (see "Outcome templates" below).
