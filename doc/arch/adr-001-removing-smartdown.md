# ADR 1: Removing Smartdown

## Context

[Smart Answers][smart-answers-github] have been historically painful to develop and maintain. In particular, relatively simple content changes can incur quite a high development cost.

[Smartdown][smartdown-github] was developed in an attempt to reduce the overhead of Smart Answers development. [Smartdown was added to the Smart Answers project on 6 Aug 2014][smartdown-in-smart-answers].

Smartdown made it easier for content designers to edit questions and outcome content, but was quite restrictive when it came to defining the rules of the Smart Answer (see the rules in [pay-leave-for-parents/partner_earned_more_than_lower_earnings_limit][spl-complicated-next-node-rules], for example).

Smartdown didn't match Ruby Smart Answers in terms of features.

As at April 2015 there were:

* 35 published (and 15 draft) Ruby Smart Answers
* 2 published (and 2 draft) Smartdown Smart Answers

## Decision

Take some of the learnings from Smartdown and use them to improve the Ruby Smart Answers.

Use ERB templates instead of [PhraseLists][phraselist-commit] to bring Ruby Smart Answer outcomes closer to Smartdown outcomes.

Convert existing Smartdown Smart Answers to Ruby.

Remove Smartdown.

## Status

Accepted.

## Consequences

It's easier for content designers to edit Smart Answer outcomes.

The Smart Answers project is simpler now that there is one less way of authoring Smart Answers.

Developers new to the Smart Answers project have one less thing to learn to get up to speed.

[phraselist-commit]: https://github.com/alphagov/smart-answers/commit/9a5e7ee0927f9da2bec0658946e14691e7e2a5c0
[smartdown-github]: https://github.com/alphagov/smartdown
[smart-answers-github]: https://github.com/alphagov/smart-answers
[smartdown-in-smart-answers]: https://github.com/alphagov/smart-answers/commit/a042c1b748819266a1e59365b07738737872e392
[spl-complicated-next-node-rules]: https://github.com/alphagov/smart-answers/blob/cbc065f78abde540165df4e376025f56261b4723/lib/smartdown_flows/pay-leave-for-parents-old/questions/partner_earned_more_than_lower_earnings_limit.txt
