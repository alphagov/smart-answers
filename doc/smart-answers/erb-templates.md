# ERB templates

Content is defined in `content_for` blocks.

Any state variable defined in the flow is available to be used in the ERB template. See [storing data](storing-data.md) for the various ways that you can set state variables.

We remove all leading spaces from the content in the `content_for` blocks before processing it using Govspeak. This allows us to indent the content in the `content_for` blocks without having to worry about it affecting the generated HTML when it's processed using Govspeak.

* [Landing page templates](landing-page-template.md)
* [Question templates](question-templates.md)
* [Outcome templates](outcome-templates.md)
