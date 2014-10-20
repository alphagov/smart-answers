Smartdown Smart Answers
=============

Smartdown flows are stored in `lib/smartdown_flows`.

The code responsible for executing the flow of those questions is in the [smartdown gem](https://github.com/alphagov/smartdown).

##Employee parental leave

Three tools specific to the employee parental leave tool were developed to facilitate question writing and fact-checking.

###Outcome generation

```rake smartdown_generate_outcomes:employee_parental_leave```

This command goes through all the outcomes listed in the Employee parental leave questions and generates outcome files that
are prepopulated with snippets.
For the employee parental leave, we use the convention of naming each outcome as an `_`-separated string of all snippets to
be listed for that outcome.

###Factcheck table generation

```rake smartdown_generate_scenarios:employee_parental_leave_factcheck```

####Output of the tool

This rake task builds four markdown documents and saves them to the ```smart-answers-factcheck``` project.
Those four markdown documents summarise the question outcomes for:
* Birth cases before 05/04/2015
* Birth cases after 05/04/2015
* Adoption cases before 05/04/2015
* Adoption cases after 05/04/2015

Each markdown document is a table summarising the answers given to each question and listing what types of maternity,
paternity, adoption, shared parental leave and pay the user(s) is/are eligible for given their answer.

####How possible combinations are generated

We have chosen for each question in the employee parental leave a selection of answers that can affect the outcome of the tool.
This is not an exhaustive list of possible answers. As the tool evolves and more legal rules are added, **possible answers
that can affect the outcome of the flow should be added to the combinations to have an accurate and complete factcheck table**.

###Scenario generation

```rake smartdown_generate_scenarios:employee_parental_leave```

This rake task prints out test scenarios files (one file per possible outcomes) to the ```smart-answers-factcheck``` project.
All those scenarios are created by using the same combination generator as the factcheck rake task.

The output is meant to be a helper when writing test scenarios for employee parental leave, and can be deprecated
once good test scenarios are put in place for that smart answer.
