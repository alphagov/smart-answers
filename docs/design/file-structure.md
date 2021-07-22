# File structure

This is an overview of the components that make up a single Smart Answer.

```
app
|__ flows
    |__ <flow-name>.rb (Required: Flow and question logic)
    |__ <flow-name>
    |   |__ start.erb (Optional: Content for the landing page)
    |   |__ outcomes
    |   |   |__ <outcome-name>.erb (Optional: Content for each outcome page)
    |   |   |__ _<partial-name>.erb (Optional: Useful when you need to share content between outcome templates)
    |   |__ questions
    |   |   |__ <question-name>.erb (Optional: Data used to build questions e.g. question and option text)
    |__ shared
        |__ <shared-directory-name>
            |__ _<partial-name>.erb (Optional: Useful when you need to share content between Smart Answers)
lib
|__ smart_answer
    |__ calculators
        |__ <calculator-name>.rb (Optional: Object encapsulating business logic for the flow)
```
