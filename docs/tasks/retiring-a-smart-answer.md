# How to retire a Smart Answer

Retiring a published Smart Answer involves using a [rake task](#removing-the-content-item) to update the content item that represents the Smart Answer flow, and then [removing the code](#remove-smart-answer-code).

## Removing the content item

Before removing a Smart Answer you will need its content_id. This is found in the relevant
`app/flows/<\smart-answer>_flow.rb` file.

For redirecting or replacing a Smart Answer you will also
need to know the paths of the pages, which are based off the `name` attribute
of the `app/flows/<\smart-answer>_flow.rb` file. For example, for
the Marriage Abroad Smart Answer the path is `/marriage-abroad`.

> NOTE: These URLs are usually cached, so you may need to wait 5-10 minutes to see the effect of these rake tasks.

### Redirecting users to a different URL

To send visitors to the Smart Answer to a new page you can run the
`unpublish_redirect` task. For example to redirect requests to a new
destination, `/random`, you'd run the following rake task:

```
bundle exec rake "publishing_api:unpublish_redirect[<content_id>,<base_path>,/random,prefix]"
```

Applying this to the [Marriage Abroad](../../app/flows/marriage_abroad_flow.rb)
Smart Answer you'd run the following command:

```
bundle exec rake "publishing_api:unpublish_redirect[d0a95767-f6ab-432a-aebc-096e37fb3039,/marriage-abroad,/random,prefix]"
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
