Smart Answers
=============

Toolkit for building smart answers. Have a look at
[`test/unit/flow_test.rb`](smart-answers/blob/master/test/unit/flow_test.rb) for example usage.

Flows are stored in `lib/flows/*.rb`. Corresponding text is in
`lib/flows/locales/*.yml`.

Testing
------------
Run unit tests by executing the following:

    bundle exec rake


Issues/todos
------------

The way that values are presented is badly factored. Values need to be
formatted for presentation in two places:

1. when displaying a collapsed question;
2. when interpolating values into question text.

Values can come from two places:

1. directly from a response (`save_input_as`);
2. via a calculation.

To correctly present a multiple-choice response value, you need to
know the question where it was posed. Other question types may also
determine formatting/presentation rules on a per-question basis so it
makes sense that it's determined at that point.

However, at present we don't remember which question gave rise to a
saved input, so this formatting is impossible.

There are two (duplicated) implementations of formatting response
labels:

1. the node presenters, e.g. `DateQuestionPresenter#response_label`
2. `NodePresenter#value_for_interpolation`

This is duplication and should be refactored out.

For now I don't think we ever need to interpolate in the responses of
multiple choice questions, so I think we can avoid this issue by:

1. determining formatting from the type of the value
2. adding a money type

The `AgeRelatedAllowanceChooser` has been created to return the
age-related personal allowance to assist with the calculation of
married couple's allowance. However, the reduction of allowances that
takes place in `MarriedCoupleAllowanceCalculator` applies to other tax
calculations, as your personal allowance depends on both your age and
income. So the `AgeRelatedAllowanceChooser` could be changed to a
`PersonalAllowanceCalculator` and extended such that it takes all those
factors into account and can be used across the system to calculate
someone's personal allowance depending on their age, income, and if
required, other factors:

[http://www.hmrc.gov.uk/incometax/personal-allow.htm]


