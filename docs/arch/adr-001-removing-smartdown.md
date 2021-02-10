# ADR 1: Removing Smartdown

## Context

[Smart Answers][smart-answers-github] have been historically painful to develop and maintain. In particular, relatively simple content changes can incur quite a high development cost.

[Smartdown][smartdown-github] was developed in an attempt to reduce the overhead of Smart Answers development. [Smartdown was added to the Smart Answers project on 6 Aug 2014][smartdown-in-smart-answers].

Smartdown made it easier for content designers to edit questions and outcome content, but was quite restrictive when it came to defining the rules of the Smart Answer (see the rules in [maternity-paternity-pay-leave/partner_earned_more_than_lower_earnings_limit][spl-complicated-next-node-rules], for example).

Smartdown didn't match Ruby Smart Answers in terms of features. Adding support for these features to Smartdown would have required extensions to the grammar and hence the parser. The cost of this would've been relatively high, especially considering that Ruby Smart Answers already had all the functionality we needed (apart from multiple questions-per-page).

The state of many of the Ruby Smart Answers would've made it hard to convert them to Smartdown without extensive refactoring.

As at April 2015 there were:

* 35 published (and 15 draft) Ruby Smart Answers
* 2 published (and 2 draft) Smartdown Smart Answers

## Decision

We will make Ruby Smart Answers as simple and accessible as possible, on the assumption that we'll have a high turnover of people working on it.

We will standardise on Ruby Smart Answers to optimise for maintenance and Business As Usual throughput.

We will take some of the learnings from Smartdown and use them to improve the Ruby Smart Answers.

We will use ERB templates instead of [PhraseLists][phraselist-commit] to bring Ruby Smart Answer outcomes closer to Smartdown outcomes.

We will convert existing Smartdown Smart Answers to Ruby.

We will remove Smartdown.

## Status

Accepted.

## Consequences

The Smart Answers application is simpler now that there is one less way of authoring Smart Answers.

Developers new to the Smart Answers project have one less thing to learn to get up to speed.

[phraselist-commit]: https://github.com/alphagov/smart-answers/commit/9a5e7ee0927f9da2bec0658946e14691e7e2a5c0
[smartdown-github]: https://github.com/alphagov/smartdown
[smart-answers-github]: https://github.com/alphagov/smart-answers
[smartdown-in-smart-answers]: https://github.com/alphagov/smart-answers/commit/a042c1b748819266a1e59365b07738737872e392
[spl-complicated-next-node-rules]: https://github.com/alphagov/smart-answers/blob/cbc065f78abde540165df4e376025f56261b4723/lib/smartdown_flows/pay-leave-for-parents-old/questions/partner_earned_more_than_lower_earnings_limit.txt
