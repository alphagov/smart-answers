# How to retire a Smart Answer

Retiring a published Smart Answer involves using a [rake task](#removing-the-content-item) to update the content item that represents the Smart Answer flow, and then [removing the code](#remove-smart-answer-code).

## Important considerations about Smart Answers

A smart answer document is a single content item that contains all possible question and answer paths for that item. Because of this, you **can not simply partially retire a Smart Answer flow**, it's an all-or-nothing affair.

There have been cases wherein a small override has had to be put in place when we wished to transition a smart answer over a period of time, rather than a straight replacement. Special care should be considered on how to handle this transition on a case by case basis.

>In an example case, wherein we were transitioning the Married Abroad smart answer flow to a new service handled by FCDO, the goal was to redirect specific smart answer entries to the new service, starting with the immediate jump from the Start page. This was complicated by the need to keep some sections of the existing smart answer available while the transition was ongoing.
>
>However, as redirecting a single part of a smart answer is impossible (due to the whole document being a single content item in our data store), we had to [explicitly override](https://github.com/alphagov/smart-answers/pull/6754/files#diff-40a1a603280835cef933a5c28f6a4248fd60cdc468d03988abc687ffcf5f7e7b) the start page link component to link to the new service.
>
>Because of how the flows are handled by, effectively, static URLs, the new service could now link back to the existing smart answer while we have effectively redirected most user-accessible ways to access the old system.

Once the transition is complete, the old smart answer can be retired through the steps below, and the override removed.

## Removing the content item

Before removing a Smart Answer you will need its content_id. This is found in the relevant
`app/flows/<\smart-answer>_flow.rb` file.

For redirecting or replacing a Smart Answer you will also
need to know the paths of the pages, which are based off the `name` attribute
of the `app/flows/<\smart-answer>_flow.rb` file. For example, for
the Check UK Visa Smart Answer the path is `/check-uk-visa`.

> NOTE: These URLs are usually cached, so you may need to wait 5-10 minutes to see the effect of these rake tasks.

### Redirecting users to a different URL

To send visitors to the Smart Answer to a new page you can run the
`unpublish_redirect` task. For example to redirect requests to a new
destination, `/random`, you'd run the following rake task:

```
bundle exec rake "publishing_api:unpublish_redirect[<content_id>,<base_path>,/random,prefix]"
```

Applying this to the [Check UK Visa](../../app/flows/check_uk_visa_flow.rb)
Smart Answer you'd run the following command:

```
bundle exec rake "publishing_api:unpublish_redirect[dc1a1744-4089-43b3-b2e3-4e397b6b15b1,/check-uk-visa,/random,prefix]"
```

### Showing users a page to indicate the content is no longer available

If there is not content to replace the Smart Answer then the convention is to
serve a page that indicates there used to be content but isn't anymore (a 410
gone HTTP response). To do this you'd run the following command:

```
bundle exec rake publishing_api:unpublish_gone[<content_id>]
```

> In exceptional circumstances, for example after accidental publishing, it is possible to remove the Smart Answer and serve
> a 404 Not Found response (instead of a 410 Gone response) which misleadingly implies that content had never been published
> there. This can be done by using the `publishing_api:unpublish_vanish` task instead. 

### Replace a Smart Answer with a different content type

Sometimes there will be a need to replace a Smart Answer with a different type
of content, typically these have been transactions, answers or start pages
which are published through [Publisher](https://github.com/alphagov/publisher).

Before a new piece of content can be recreated with the same URL, you will need to perform a 
temporary removal of the Smart Answer page(s) to be replaced. You can use the 
[`publishing_api:unpublish_gone` task](#showing-users-a-page-to-indicate-the-content-is-no-longer-available)
to perform this.

You can then run a rake task command to reserve the path(s) used by the Smart
Answer for a different publishing application. For example, to reserve the
Marriage Abroad start page for Publisher you can perform the following command:

```
bundle exec rake "publishing_api:change_owning_application[/marriage-abroad,publisher]"
```

You can then create a new piece of content with the URL previously used by the Smart Answer.

> NOTE: Start pages once existed in Publisher, and artefacts may persist in Publisher's
> database with current Smart Answer slugs. This may prevent a Smart Answer being replaced
> by a new document type as Publisher is still reserving the slug. [You will need to delete
> the old artefact](https://github.com/alphagov/publisher/pull/1474/files), once confirmed
> it is no longer needed.


## Remove Smart Answer code

Remove all the files and directories associated with the individual Smart
Answer and their associated tests. Examples of common files are:

- Flow class files
  - app/flows/<\smart-answer>\_flow.rb
- ERB templates directory
  - app/flows/<\smart-answer>\_flow
- YAML files
  - config/smart_answers/rates/<\smart-answer>.yml
  - config/smart_answers/<\smart-answer>.yml
- Calculators, data query and other ruby files
  - lib/smart_answer/calculators/<\smart-answer>\_calculator.rb
  - lib/smart_answer/calculators/<\smart-answer>\_data_query.rb
