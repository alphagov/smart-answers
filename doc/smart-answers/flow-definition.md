# Flow

At the heart of each Smart Answer is a subclass of `SmartAnswer::Flow`. Subclasses like this make a DSL available for [specifying metadata](#metadata), and [defining](#definition) all the [question nodes](#question-nodes), the [outcome nodes](#outcome-nodes), and the [rules](next-node-rules.md) to control routing between the nodes.

## Naming

The flow filename should be based on the path where the Smart Answer is to be found on gov.uk. For example, for a Smart Answer at https://www.gov.uk/example-smart-answer, the flow file should be named `lib/smart_answer_flows/example-smart-answer.rb`. Similarly the template directory should be named `lib/smart_answer_flows/example-smart-answer/`.

The flow class should be a camel-case version of the flow filename with the suffix, `Flow` e.g. in the case above it would be `ExampleSmartAnswerFlow`. The class should inherit from `SmartAnswer::Flow` and be in the `SmartAnswer` namespace.

For example:

```ruby
# lib/smart_answer_flows/example-smart-answer/example-smart-answer.rb
module SmartAnswer
  class ExampleSmartAnswerFlow < Flow
    def define
      # flow definition specified here
    end
  end
end
```

> Note that much of the above does not follow standard Ruby or Rails conventions which isn't ideal. However, the plan is to move towards using such conventions as soon as possible.

## Definition

The flow is defined within the `define` instance method of the `Flow` subclass using a DSL to specify metadata, question nodes and outcome nodes.

> Unfortunately this DSL is overly complex and makes it all too easy to create code which is very hard to follow. The DSL makes heavy use of Ruby's [`BasicObject#instance_eval`][instance-eval] & [`#instance_exec`][instance-exec]. This means that:
>
> * It's not obvious what variables are in scope within a given block of code.
> * It's all too easy to write arbitrary custom code which can make each flow a bit of a special case. This doesn't help on the maintainability front.
> * It's confusing that blocks of code are not necessarily executed in the order that they appear in the flow definition.
> * The code in the blocks is not easily unit-testable.

Each flow is instantiated in the [`FlowRegistry`][flow-registry] via the `Flow.build` method which, in turn, instantiates the flow and invokes its `Flow#define` method.

Currently when the app is running in the Rails `development` & `production` environments (but not in `test`) a single instance of each flow class is instantiated at application start-up (or strictly speaking on the first request) and cached in the `FlowRegistry` i.e. the same instance of a particular flow class is used to service all the user requests involving that Smart Answer. Thus it's important that no request-specific state is stored on the flow instance, otherwise this could leak into other user requests.

It's important to understand this distinction between "flow definition time" and "request time" when trying to understand a flow definition. A number of the sections below refer to this distinction.

### Metadata

There are a number of methods on `SmartAnswer::Flow` which allow "metadata" for the flow to be specified:

```ruby
module SmartAnswer
  class ExampleSmartAnswerFlow < Flow
    def define
      name 'example-smart-answer' # this is the path where the Smart Answer will be registered on gov.uk (via the publishing-api)
      content_id "bfda3b4f-166b-48e7-9aaf-21bfbd606207" # a UUID used by v2 of the Publishing API (?)
      status :published # this indicates whether or not the flow is available to be published to live gov.uk , those with `:draft` status will be available on draft gov.uk
      satisfies_need "7da2fa63-190c-446e-b3e5-94480f0e46e7" # relates the Smart Answer to a Need managed by Maslow
      external_related_links { title: "Child Maintenance Options - How much should be paid",
                               url: "http://www.cmoptions.org/en/maintenance/how-much.asp" } # External links associated to the Smart-Answer
      button_text "Continue" # optional - replaces the default "Next step" button label with the passed in text

      # question & outcome definitions specified here
    end
  end
end
```

* `external_related_links` will be stored in [content-tagger](https://github.com/alphagov/content-tagger) with the objective of retrieving them from there. This is a temporary fix, we want to be able to set external related links via a publishing tool like `content-tagger` rather than hardcoding them.

### Arbitrary Ruby code

Since the flow definition is just the body of a standard Ruby method, it's possible to write arbitrary Ruby code at any point within it. Arbitrary Ruby code is pretty much anything other than calls to the DSL methods described in this document. The use of a local variable at the top-level of the `#define` method and used later within a block is an example of arbitrary Ruby code which is explained in more detail below.

> It should be possible to implement the majority of flows *without* writing such arbitrary Ruby code. Any decision to introduce such arbitrary code should be very carefully considered, particularly regarding it's maintainability.

> Some exceptions to the "no arbitrary Ruby" rule are: instantiating and storing a "calculator" object (in an `on_response` block), storing a response on the "calculator" object, and conditional logic within a `next_node` block. Although even the latter should be kept to a minimum by extracting predicate methods onto the "calculator" object.

Since the flow definition is just the body of a `Flow` instance method (`#define`), the value of `self` at the "top-level" within the method is an instance of the flow.

#### Local variables

Some flows (e.g. [register-a-birth][local-variable-in-flow-definition]) define local variables towards the top of the flow definition. Standard Ruby scoping means that these are then available within question & outcome blocks, as well as within blocks nested inside these blocks. However, note that the value of the local variable is set at flow definition time and *not* at request time. Since a single flow instance is cached in the `FlowRegistry` at application start-up time, this means the local variable is _only assigned once_.

### Start node

Every flow has an implicit start node which represents the "landing page" i.e. the page which displays the "Start" button. There is no representation of this start node in the flow definition. Clicking the "Start" button on the "landing page" takes you to the page for the first question node (see below).

Also see the documentation for [landing page templates](/doc/smart-answers/erb-templates/landing-page-template.md).

### Question nodes

There is an implicit assumption that the question definition which appears first in the flow definition is the first question of the flow. All other "routing" between nodes is [done explicitly](next-node-rules.md) in a single `next_node` block per question node.

By convention, question nodes are usually listed roughly in the order that a user would visit them. Although this isn't always straightforward when there are multiple paths through the flow.

Since all "routing" is done explicitly within `next_node` blocks, the order of the question definitions (other than the first one) is functionally unimportant.

By convention, all question nodes are defined *before* any of the outcome nodes. However, again the order is functionally unimportant.

Question nodes are defined by calls to one of the various [question-type methods](question-types.md). Since the value of `self` at the "top-level" within the `#define` method is an instance of the flow, these question-type methods are defined on the `SmartAnswer::Flow` base class.

For example:

```ruby
module SmartAnswer
  class ExampleSmartAnswerFlow < Flow
    def define
      # self = instance of SmartAnswer::Flow

      # metadata specified here

      radio :question_key do
        option :option_key_1
        option :option_key_2

        # optional blocks specified here

        next_node do
          # routing logic specified here
        end
      end
    end
  end
end
```

See [In-question blocks](#in-question-blocks) below for more information on the optional blocks mentioned in a comment in the example.

#### Scope

The value of `self` inside the question node definition block (but outside other blocks) is the instance of the relevant question node. Thus in the example above, the calls to `#option` and `#next_node` are made on the instance of the question node.

In the same way that there is a single instance of each flow class, there is only ever a single instance of each question definition in the system at any one time i.e. a flow instance has a fixed set of question node definition instances.

Since the same instance of a question definition is used across multiple requests, it's important that no request-specific state is stored on them.

The value of `self` inside the `next_node` blocks (or the other [in-question blocks](#in-question-blocks)) is an instance of `SmartAnswer::State` ([see below](#state)), i.e. *not* an instance of a question node.

```ruby
def define
  # self = instance of SmartAnswer::Flow

  value_question :question_key do
    # self = instance of SmartAnswer::Question::Value

    on_response do |response|
      # self = instance of SmartAnswer::State
    end

    next_node do
      # self = instance of SmartAnswer::State
    end
  end
end
```

#### Execution

The code inside the question node definition block (but outside other blocks) is executed at _flow definition time_, not at request time. However, the code inside the `next_node` blocks (or the other optional blocks) is executed at _request time_, not at flow definition time.

```ruby
def define
  # executed at flow definition time

  value_question :question_key do
    # executed at flow definition time

    on_response do |response|
      # executed at request time
    end

    next_node do
      # executed at request time
    end
  end
end
```

#### State

The state object is intended to store all request-specific state, keeping that away from the instance of the flow which is reused across multiple requests. `SmartAnswer::State` inherits from `OpenStruct` and uses [`BasicObject#method_missing`][method-missing]
to allow arbitrary "state variables" to be written and read.

```ruby
state = SmartAnswer::State.new(:first_node)
state.example_state_variable = 123
state.example_state_variable # => 123
```

Since the request path only includes the user's responses and *not* the question keys, and the app is stateless, *every* request has to be processed by walking through the question definition nodes starting at the first one. As a request is processed, the state is duplicated using [`Object#dup`][object-dup] in each "transition" to a new node.

```ruby
state = SmartAnswer::State.new(:first_node)
state.example_state_variable = 123
new_state = state.transition_to(:second_node, 'first-response')
new_state.equal?(state) # => false (i.e. they are *different* instances)
new_state.example_state_variable # => 123
```

It's important to note that `Object#dup` does not do a "deep" copy. Thus any "state variables" set on the state which are references to other objects will continue to reference the _same_ instances of those other object - those objects will *not* themselves be duplicated. The *only* exceptions to this are two built-in state variables, `responses` & `path` ([see below](#built-in-state-variables)) which are themselves duplicated using `Object#dup` in `State#initialize_copy`.

```ruby
state = SmartAnswer::State.new(:first_node)
state.example_state_variable = [1, 2, 3]
new_state = state.transition_to(:second_node, 'first-response')
new_state.example_state_variable # => [1, 2, 3]
new_state.example_state_variable.equal?(state.example_state_variable)
# => true (i.e. they are the *same* instance)
```

> Since a new instance of the state is created for each request, it's not obvious _why_ the state is duplicated in this way. I know that in the past there have been problems with state leaking between requests, so perhaps this was a mistaken attempt at preventing such leakage.

It's possible to [view the state](viewing-state.md) when you're running the app in the development environment.

##### Built-in state variables

* `current_node` - symbol key for the node being processed
* `path` - array of symbol keys for nodes previously processed
* `responses` - user responses parsed from request path; usually strings (?)
* `response` - always `nil` (?)
* `error` - key for validation error message to display; usually a string (?)

```ruby
state = SmartAnswer::State.new(:first_node)
# => #<SmartAnswer::State current_node=:first_node, path=[], responses=[], response=nil, error=nil>
first_state = state.transition_to(:second_node, 'first-response')
# => #<SmartAnswer::State current_node=:second_node, path=[:first_node], responses=["first-response"], response=nil, error=nil>
second_state = first_state.transition_to(:third_node, 'second-response')
# => #<SmartAnswer::State current_node=:third_node, path=[:first_node, :second_node], responses=["first-response", "second-response"], response=nil, error=nil>
```

> Note that some of the application code (e.g. illegal radio response) erroneously sets the error key to the validation error message *string*. Since this string is not the *key* to an error message, the default error message is displayed.

#### In-question blocks

All question definition blocks, must include a single `next_node` block. A number of other in-question blocks can optionally be defined by passing a block to any of the following methods on `SmartAnswer::Node` & `SmartAnswer::Question::Base`: `on_response`, `validate`, `next_node` & `calculate`. The `save_input_as` method is used in a similar way, but does not accept a block.

The value of `self` inside all these blocks is an instance of `SmartAnswer::State` ([see above](#state)). The code inside these blocks is executed at request time, not at flow definition time.

All blocks of a particular type (within a single question) are executed at particular points in the request processing sequence e.g. all `on_response` blocks are executed before all `validate` blocks.

The order in which the blocks are defined only affects the order in which they are executed within the group of blocks of the same type e.g. when two `on_response` blocks are defined, the one defined first will be executed before the one defined second; however, even if a `validate` block is defined before both of these `on_response` blocks, it will always be executed after both of them.

The block types are executed in the following order:

* [`on_response`](#on_responseblock)
* [`validate`](#validatemessage_key-block)
* [`next_node`](#next_nodeblock)
* [`save_input_as`](#save_input_asvariable_name)
* [`calculate`](#calculatevariable_name-block)

Each of these block types and the point at which they are executed is explained in more detail below:

##### `on_response(&block)`

* These blocks are intended to be used to store user responses on a `calculator` state variable. They are a [relatively new addition to the DSL][introduction-of-on-response-blocks].
* These blocks are called after the question/outcome template has been rendered and after the user response has been parsed from the request path, but before any of the `validate` blocks are executed.
* The parsed response is passed to the block as the only argument and by convention is named `response`.
* The block return value is not used and no state variable is stored.

> The use of these blocks is encouraged; however, they should only ever be used to store a single, `calculator` state variable (in the first question definition); otherwise they should only be used to store user responses on that `calculator` object.

##### `validate(message_key, &block)`

* These blocks are intended to be used to validate the user response.
* These blocks are executed after all the `on_response` blocks have been executed and before the `next_node` block is executed.
* The parsed response is passed to the block as the only argument and by convention is named `response`.
* If the block return value is truth-y, then no action is taken.
* If the block return value is false-y, then:
  1. A `SmartAnswer::InvalidResponse` exception is raised with the `message_key` set as the exception message.
  2. This exception is handled within the app and prevents the transition to the next node.
  3. The `message_key` from the exception message is set on the built-in state variable, `error`.
  4. When the question template is re-rendered, the `error` state variable is used to lookup the appropriate validation error message in the [question template](/doc/smart-answers/erb-templates/question-templates.md#error_messagemessage).

> The use of these blocks is encouraged. However, they should call `valid_xxx?` methods on the `calculator` state variable and not rely on the `response` argument passed into the block.

```ruby
# Good
validate :error_outside_range do
  calculator.valid_weekly_amount_in_range?
end

# Bad
validate do |response|
  calculator.valid_age?(response)
end
```

##### `next_node(&block)`

* There must only be one of these blocks per question definition.
* This block is intended to determine which node comes next based on the user responses so far.
* These blocks are executed after all the `validate` blocks have been executed and before any `save_input_as` blocks are executed.
* The built-in state variables, `path`, `current_node` & `responses`, are updated if this block returns successfully.
* The block return value must be the result of calling the `#question` or `#outcome` methods passing in the key of the next node - see the [next node documentation](next-node-rules.md) for more details.

> The use of this block type is *required*. However, it should call methods on the `calculator` state variable and not rely on the `response` argument passed into the block.

##### `save_input_as(variable_name)`

* Although you can call this method multiple times within a single question, only the last call will actually have any effect.
* This method is intended to allow you to store the response to the current question for use in blocks in *subsequent* nodes.
* The response is stored after the `next_node` block has been executed and before any `calculate` blocks are executed.
* The response is stored on the state object as a state variable named `variable_name`.

> The use of these blocks is deprecated and should never be necessary; `on_response` blocks should be used instead.

##### `calculate(variable_name, &block)`

* These blocks were intended to be used to store state variables that are needed in subsequent questions or outcomes.
* These blocks are executed after `save_input_as` has executed.
* The parsed response is passed to the block as the only argument and by convention is named `response`.
* The block return value is stored on the state object as a state variable named `variable_name`.

> The use of these blocks is deprecated and should never be necessary. Define methods on a `calculator` object instead.

#### Further information

See the [documentation on storing data](storing-data.md).

#### Templates

See the [documentation for question templates](/doc/smart-answers/erb-templates/question-templates.md).

### Outcome nodes

These are very similar to question nodes. There should never be a response associated with an outcome node. Having said that, the following methods are all _technically_ available within the node definition, because they are instance methods on `SmartAnswer::Outcome` (or its superclasses):

* [`on_response`](#on_responseblock)
* [`calculate`](#calculatevariable_name-block)

If any attempt is made to process a response when the current node is an outcome node (e.g. by hacking the URL path), an exception will be raised.

#### Templates

See the [documentation for outcome templates](/doc/smart-answers/erb-templates/outcome-templates.md).

[instance-eval]: http://ruby-doc.org/core-2.6.1/BasicObject.html#method-i-instance_eval
[instance-exec]: http://ruby-doc.org/core-2.6.1/BasicObject.html#method-i-instance_exec
[method-missing]: http://ruby-doc.org/core-2.6.1/BasicObject.html#method-i-method_missing
[object-dup]: http://ruby-doc.org/core-2.6.0/Object.html#method-i-dup
[local-variable-in-flow-definition]: https://github.com/alphagov/smart-answers/blob/20d2d9f524e912a3edcb9256ce2d790059538641/lib/smart_answer_flows/register-a-birth.rb#L9-L12
[introduction-of-on-response-blocks]: https://github.com/alphagov/smart-answers/pull/2408
[flow-registry]: https://github.com/alphagov/smart-answers/blob/cc6c5050bb78d0085cffe0a40630784724aa062a/lib/smart_answer/flow_registry.rb
