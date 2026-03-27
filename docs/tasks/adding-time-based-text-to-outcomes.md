# Adding time-based text to outcomes

Sometimes there is a need to temporarily display text on outcomes. For example, when a policy change is occuring and there is a grace period where some transitional rules apply.

The display of such text can be wrapped in a conditional that checks the current date and time. The text and its surrounding conditional can then be removed at leisure, to avoid having to make a time-sensitive deployment to remove the temporary text.

## Example
```erb
<% if Time.zone.now <= Time.zone.local(2025, 4, 23, 15) %>
    ##If you’re arriving in the UK before 3pm (UK time) on 23 April 2025

    Some text that applies to people arriving before the deadline.
<% end %>
```

[Example PR](https://github.com/alphagov/smart-answers/pull/7527)
