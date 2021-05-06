# ADR 3: Outcome-centric Logic

## Problem

Some of our Smart Answer flows have become very difficult to read and understand.
This is down to two factors: liberal use of nesting, and different branches of logic leading to the same outcomes.

As a result, it can be very difficult to give an answer to the question "how do I reach outcome X?". It can also be difficult to deduce whether multiple conditions can lead to the same outcome.

This makes the code harder to work with, slowing pace of delivery and increasing the likelihood of bugs.

We've identified three Smart Answers which have these issues:

- [pay-leave-for-parents](https://github.com/alphagov/smart-answers/blob/7cc0ca0c85fe9de04d859e705dbe9b9b5d402306/lib/smart_answer_flows/pay-leave-for-parents.rb#L251-L459)
- [check-uk-visa](https://github.com/alphagov/smart-answers/blob/7cc0ca0c85fe9de04d859e705dbe9b9b5d402306/lib/smart_answer_flows/check-uk-visa.rb#L194-L221)
- [uk-benefits-abroad](https://github.com/alphagov/smart-answers/blob/7cc0ca0c85fe9de04d859e705dbe9b9b5d402306/lib/smart_answer_flows/uk-benefits-abroad.rb#L163-L188)

## Proposal

Instead of calculating in terms of the user's answers, we should treat each outcome in turn, and calculate whether the user's answers should qualify for that outcome. Here is a [proof of concept](https://github.com/alphagov/smart-answers/commit/a5ab26089b2dd77815d35b80c8960c86a08a1661) for one portion of one of the offending Smart Answer flows.

This approach:

1. defines the required conditions on a per-outcome basis, so it's much easier to reason about how to get to a particular outcome
1. flattens the heavily nested and complex structure, making it easier to make changes to the logic.

If we look at the vast majority of Smart Answer flows which do _not_ suffer from this spaghetti code, such as the Register a Birth Smart Answer, the logic [is very easy to follow](https://github.com/alphagov/smart-answers/blob/7cc0ca0c85fe9de04d859e705dbe9b9b5d402306/lib/smart_answer_flows/register-a-birth.rb). Note that for each 'node', there is only one branch of logic to arrive at a particular outcome, and there is no nesting. In other words, **most Smart Answers already use an outcome-centric approach**.

This proposal is to bring _all_ Smart Answers in line, by following these rules:

```
for every smart answer flow:
  for every node in the flow:
    - each outcome is only defined once
    - there is only one level of indentation
      (i.e. if/else and case statements are allowed, but no nesting)
```

This should bring all of our Smart Answers up to roughly the same readability standard, and we'll then have this ADR we can point our developers to, to prevent this from happening again.

### Suggested steps for implementation

Convert `pay-leave-for-parents.rb`, `check-uk-visa.rb` and `uk-benefits-abroad.rb` to be outcome-centric rather than input-centric. These are the worst offenders and would benefit most from the refactor.

Then there are some small tweaks required to other smart answer flows - see 'Example conversion' below.

Once all Smart Answers have been refactored to the same standard, there are [additional improvements we could consider](#additional-improvements). These are outside of the scope of this ADR, but are included for completion.

### Example conversion

Consider this block of code from [student-finance-calculator](https://github.com/alphagov/smart-answers/blob/7cc0ca0c85fe9de04d859e705dbe9b9b5d402306/lib/smart_answer_flows/student-finance-calculator.rb#L155-L179):

```ruby
next_node do |response|
  case calculator.course_type
    when "uk-full-time"
      if response == "dental-medical-healthcare"
        question :are_you_a_doctor_or_dentist?
      else
        outcome :outcome_uk_full_time_students
      end
    when "uk-part-time"
      outcome :outcome_uk_all_students
    else
      outcome :outcome_eu_students
    end
end
```

To follow the proposal of this ADR, we'd change the code to this:

```ruby
next_node do |response|
  if calculator.course_type == "uk-full-time" && response == "dental-medical-healthcare"
    question :are_you_a_doctor_or_dentist?
  elsif calculator.course_type == "uk-full-time"
    outcome :outcome_uk_full_time_students
  elsif calculator.course_type == "uk-part-time"
    outcome :outcome_uk_all_students
  else
    outcome :outcome_eu_students
  end
end
```

Whilst there is slightly more repetition with the new approach, it's also easy to see at a glance what the conditions are to reach each outcome/question.

### Additional improvements

As stated earlier, these ideas are out of scope for the ADR, but are included for completion.

After ADR 3 is implemented, we could build some linting into our build pipeline to prevent any violations of the proposed rules. For example, we could parse each node to:

1. detect whether an outcome or question occurs more than once.
1. detect whether any additional `case`/`if` statements occur inside an 'unclosed' `case`/`if`.

Taking this even further, we could prevent such issues programmatically by moving Smart Answers to a state machine architecture. If we can express every outcome in terms of its conditions, we could represent each node as data rather than logic - here is how the above example might be represented:

```ruby
[
  are_you_a_doctor_or_dentist?: -> { calculator.course_type == "uk-full-time" && response == "dental-medical-healthcare" },
  outcome_uk_full_time_students: -> { calculator.course_type == "uk-full-time" },
  outcome_uk_all_students: -> { calculator.course_type == "uk-part-time" },
  outcome_eu_students: true,
]
```

This would prevent developers from being able to repeat the same outcome/question more than once per node, and limit their ability to introduce complex logic for each outcome.

## Status

Proposed.
