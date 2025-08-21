# Creating a new Smart Answer

There are two methods for creating a new smart answer:
  1. automatically - via a rails generator, and
  2. manually.

## Using the rails `smart_answer` generator

To automatically generate a skeleton smart answer use the provided rails
generator...

```bash
$ rails generate smart_answer my_smart_answer
```

This will create an example flow, calculator, questions, outcome and landing
pages.

The generated files do not constitute a complete set of all possible question
types, and configuration options. However, they should be enough to get you
started and to show how the various files work together.

To see a list of the files that the generator will create use either the
`--help` or `--pretend` options, like this...

```bash
$ rails generate smart_answer --help
$ rails generate smart_answer my_smart_answer --pretend
```

## Manually creating a new Smart Answer

This walks through the basics of manually creating a new Smart Answer.

### 1. Create a new skeleton flow

Start by creating a new file to hold the logic of our flow:

```bash
$ touch app/flows/example_smart_answer_flow.rb
```

Open the new file in your editor and copy/paste this skeleton flow:

```ruby
class ExampleSmartAnswerFlow < SmartAnswer::Flow
  def define
    name 'example-smart-answer'
    content_id "<SecureRandom.uuid>"
    status :draft

    value_question :question_1? do
      next_node do
        outcome :outcome_1
      end
    end

    outcome :outcome_1
  end
end
```

This flow contains a single question and a single outcome. Any non-empty response to `:question_1?` will send you to `:outcome_1`.

If you were to run `rails server` and visit [http://localhost:3000/example-smart-answer][example-smart-answer] at this point, you'd see an error that indicates that we need to add a landing page template.

### 2. Create an ERB landing page template

Create a new file for our landing page template.

```
$ mkdir app/flows/example_smart_answer_flow
$ touch app/flows/example_smart_answer_flow/start.erb
```

Although the landing page template needs to exist, it doesn't actually need to contain anything!

Assuming you're still running `rails server`, visit [http://localhost:3000/example-smart-answer][example-smart-answer] and you should see the empty landing page of our new Smart Answer.

Open the new landing page template your editor and copy/paste the following content:

```erb
<% text_for :title do %>
  Smart Answer title
<% end %>

<% govspeak_for :body do %>
  Landing page body.
<% end %>
```

Refresh the Smart Answer in your browser to see this new content.

Read more about [landing page templates](../design/erb-templates/landing-page-template.md).

Click "Start now" to visit the first question. You should see an error message indicating that we're now missing an ERB template for our question.

### 3. Create an ERB question page template

Create a new file for our question page template.

```
$ mkdir app/flows/example_smart_answer_flow/questions
$ touch app/flows/example_smart_answer_flow/questions/question_1.erb
```

Although the question page template needs to exist, it doesn't actually need to contain anything!

Assuming you're still running `rails server`, visit [http://localhost:3000/example-smart-answer][example-smart-answer] and you should see an empty page containing a text field and a "Continue" button.

Open the new question page template in your editor and copy/paste the following content:

```erb
<% text_for :title do %>
  Question page title
<% end %>

<% govspeak_for :body do %>
  Question page body.
<% end %>
```

Refresh the Smart Answer in your browser to see this new content.

Read more about [question page templates](../design/erb-templates/question-templates.md).

Enter any value in the text field and click "Continue". You should see an error message indicating that we're now missing an ERB template for the outcome.

### 4. Create an ERB outcome page template

Create a new file for our outcome page template.

```
$ mkdir app/flows/example_smart_answer_flow/outcomes
$ touch app/flows/example_smart_answer/outcomes/outcome_1.erb
```

Although the question page template needs to exist, it doesn't actually need to contain anything!

Assuming you're still running `rails server`, visit [http://localhost:3000/example-smart-answer][example-smart-answer] and you should see an empty page containing a list of "Your answers".

Open the new outcome page template in your editor and copy/paste the following content:

```erb
<% text_for :title do %>
  Outcome page title
<% end %>

<% govspeak_for :body do %>
  Outcome page body.
<% end %>
```

Refresh the Smart Answer in your browser to see this new content.

Read more about [outcome page templates](../design/erb-templates/outcome-templates.md).

[example-smart-answer]: http://localhost:3000/example-smart-answer

### 5. Publish the new Smart Answer

Follow the instructions for [publishing a Smart Answer](publishing.md) to ensure the changes are synchronised on the Publishing API and live on GOV.UK.

And that's all there is to an incredibly simple Smart Answer.

