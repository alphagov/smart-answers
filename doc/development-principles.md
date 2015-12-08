# Smart Answer flows - Development principles

## Do's

* Make small improvements to the code before making even business-as-usual changes. See [refactoring existing Smart Answers](refactoring.md) for some common improvements.

* Make use of the higher-level abstractions available in the project, for example the `DateRange`, `YearRange` and `TaxYear` classes.

* Extract more higher-level abstractions where the same behaviour is being duplicated across multiple flows.

* Model the domain of the policy/rules that make up a Smart Answer.

* Ensure all policy logic is encapsulated in objects that are instantiated by (but separate from) the flow.

* Ensure all presentation logic is kept in the ERB templates and associated helper methods.

* Ensure the Smart Answer flows only contain routing (`next_node`) logic.

* Iteratively develop new Smart Answers. Get a simply happy-path version deployed and build upon that in collaboration with the department and content team.

## Dont's

* Don't copy the style of existing "legacy" Smart Answers (e.g. [calculate-agricultural-holiday-entitlement](https://github.com/alphagov/smart-answers/blob/829837f1f738c711985bf3a7a5d1655605637edd/lib/smart_answer_flows/calculate-agricultural-holiday-entitlement.rb)).

* Don't blindly follow the logic documents when creating/amending Smart Answers. This has lead to some of the problems we see in the "legacy" Smart Answers, e.g. policy logic being mixed up with flow/routing logic resulting in hard to maintain code.

* Don't do big-bang development of new Smart Answers. See the point about iteratively developing them in the "Do's" section above.
