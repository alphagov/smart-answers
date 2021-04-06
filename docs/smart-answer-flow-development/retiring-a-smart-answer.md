# How to retire a Smart Answer

The process to retire a published Smart Answer involves
[removing the code](#remove-smart-answer-code) for the Smart Answer and then
using an [unpublish task](#removing-from-govuk) to update GOV.UK the two
distinct content items that comprise of a Smart Answer.

## Remove Smart Answer code

Remove all the files and directories associated with the individual Smart
Answer and their associated tests, examples of common files:

- Flow class files
  - lib/smart_answer_flows/<\smart-answer-name>.rb
- ERB templates directory
  - lib/smart_answer_flows/<\smart-answer-name>
- YAML files
  - config/smart_answers/rates/<\smart-answer-name>.yml
  - config/smart_answers/<\smart-answer-name>.yml
- Calculators, data query and other ruby files
  - lib/smart_answer/calculators/<\smart-answer-name>\_calculator.rb
  - lib/smart_answer/calculators/<\smart-answer-name>\_data_query.rb

## Removing from GOV.UK

Before removing a Smart Answer you will need the content_id of both the start
page and flow page for the Smart Answer. These can be found in the
`lib/smart_answer_flows/<\smart-answer-name>.rb` file of the Smart Answer that
is being retired. For redirecting or replacing a Smart Answer you will also
need to know the paths of these pages these are based off the `name` attribute
of the `lib/smart_answer_flows/<\smart-answer-name>.rb` file. For example, for
the Marriage Abroad Smart Answer the path of the start page is `/marriage-abroad`
and the path of the flow page is `/marriage-abroad/y`.

### Redirecting users to a different URL

To send visitors to the Smart Answer to a new page you can run the
`unpublish_redirect` task. For example to redirect the start page and flow page
to a new destination, `/random`, you'd run the following rake tasks:

```
bundle exec rake "publishing_api:unpublish_redirect[<content_id>,<start_page_path>,/random,prefix]"
bundle exec rake "publishing_api:unpublish_redirect[<flow_page_content_id>,<flow_page_path>,/random]"
```

Applying this to the [Marriage Abroad](../../lib/smart_answer_flows/marriage-abroad.rb)
Smart Answer you'd run the following commands:

```
bundle exec rake "publishing_api:unpublish_redirect[d0a95767-f6ab-432a-aebc-096e37fb3039,/marriage-abroad,/random,prefix]"
bundle exec rake "publishing_api:unpublish_redirect[92c0a193-3b3b-4378-ba43-279e7274b7e7,/marriage-abroad/y,/random]"
```

### Showing users a page to indicate the content is no longer available

If there is not content to replace the Smart Answer then the convention is to
serve a page that indicates there used to be content but isn't anymore (a 410
gone HTTP response). An example of how to perform this on both pages is:

```
bundle exec rake publishing_api:unpublish_gone[<content_id>]
bundle exec rake publishing_api:unpublish_gone[<flow_page_content_id>]
```

> It is possible to remove the Smart Answer and rather than serve a 410 Gone
> page instead serve a 404 Not Found, which misleads visitors to the page that
> content had never been published there. This can be done by using the
> `publishing_api:unpublish_vanish` task instead of the gone equivalent. This
> task should only be used in exceptional circumstances for example an
> accidental early publishing of content with a sensitive URL.

### Replace a Smart Answer with a different content type

Sometimes there will be a need to replace a Smart Answer with a different type
of content, typically these have been transactions, answers and start pages
that can be published through [Publisher](https://github.com/alphagov/publisher).

The next step is to perform a temporary removal of the Smart Answer page(s) to
be replaced. You can use the [aforementioned `publishing_api:unpublish_gone`
task](#showing-users-a-page-to-indicate-the-content-is-no-longer-available)
to perform this.

You can then run a rake task command to reserve the path(s) used by the Smart
Answer for a different publishing application. For example, to reserve the
Marriage Abroad start page for Publisher you can perform the following command:

```
bundle exec rake "publishing_api:change_owning_application[/marriage-abroad,publisher]"
```

Once this is complete you can then create a new piece of content with the URL
the Smart Answer page previously used.

> If you are replacing the start page of the Smart Answer with a page from a
> different publishing application don't forget to redirect or remove the flow
> page as well.
