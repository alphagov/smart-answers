# Creating a new Smart Answer

This walks through the basics of creating a new Smart Answer.

## 1. Create a new skeleton flow

Start by creating a new file to hold the logic of our flow:

```bash
$ touch lib/smart_answer_flows/example-smart-answer.rb
```

Open the new file in your editor and copy/paste this skeleton flow:

```ruby
module SmartAnswer
  class ExampleSmartAnswerFlow < Flow
    def define
      name 'example-smart-answer'

      value_question :question_1 do
        next_node :outcome_1
      end

      outcome :outcome_1
    end
  end
end
```

This flow contains a single question and a single outcome. Any non-empty response to `:question_1` will send you to `:outcome_1`.

If you were to run `rails server` and visit http://localhost:3000/example-smart-answer at this point, you'd see an error that indicates that we need to add a landing page template.

## 2. Create an ERB landing page template

Create a new file for our landing page template.

```
$ mkdir lib/smart_answer_flows/example-smart-answer
$ touch lib/smart_answer_flows/example-smart-answer/example_smart_answer.govspeak.erb
```

Although the landing page template needs to exist, it doesn't actually need to contain anything!

Assuming you're still running `rails server`, visit http://localhost:3000/example-smart-answer and you should see the empty landing page of our new Smart Answer.

Click "Start now" to visit the first question. You should see an error message indicating that we're now missing an ERB template for our question.

## 3. Create an ERB question page template

Create a new file for our question page template.

```
$ mkdir lib/smart_answer_flows/example-smart-answer/questions
$ touch lib/smart_answer_flows/example-smart-answer/questions/question_1.govspeak.erb
```

Although the question page template needs to exist, it doesn't actually need to contain anything!

Assuming you're still running `rails server`, visit http://localhost:3000/example-smart-answer and you should see an empty page containing a text field and a "Next step" button.

Enter any value in the text field and click "Next step". You should see an error message indicating that we're now missing an ERB template for the outcome.

## 4. Create an ERB outcome page template

Create a new file for our outcome page template.

```
$ mkdir lib/smart_answer_flows/example-smart-answer/outcomes
$ touch lib/smart_answer_flows/example-smart-answer/outcomes/outcome_1.govspeak.erb
```

Although the question page template needs to exist, it doesn't actually need to contain anything!

Assuming you're still running `rails server`, visit http://localhost:3000/example-smart-answer and you should see an empty page containing a list of "Previous answers".

And that's all there is to an incredibly simple Smart Answer.
