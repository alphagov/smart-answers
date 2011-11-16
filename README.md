Smart Answers
=============

Toolkit for building smart answers. Have a look at test/unit/flow_test.rb for example usage.

Flows are stored in lib/flows/*.rb. Corresponding text is in lib/flows/locales/*.yml

Issues/todos
============

The way that values are presented is badly factored. Values need to be formatted for presentation in two places:- (i) when displaying a collapsed question; (ii) when interpolating values into question text.

Values can come from two places:- (i) directly from a response (save_input_as); (ii) via a calculation.

To correctly present a multiple-choice response value, you need to know the question where it was posed. Other question types may also determine formatting/presentation rules on a per-question basis so it makes sense that it's determined at that point.

However, at present we don't remember which question gave rise to a saved input, so this formatting is impossible.

There are two (duplicated) implementations of formatting response labels:

i) the node presenters, e.g. DateQuestionPresenter#response_label
ii) NodePresenter#value_for_interpolation

This is duplication and should be refactored out.

For now I don't think we ever need to interpolate in the responses of multiple choice questions, so I think we can avoid this issue by:

i) determining formatting from the type of the value
ii) adding a money type
