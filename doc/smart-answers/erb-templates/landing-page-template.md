# Landing page template

Landing page templates live in `lib/smart_answer_flows/<flow-name>/<flow-name-with-underscores>.govspeak.erb`.

## Content types

The templates can contain content for any of the following keys:

### `:title`

* Default format is `:text`
* Used as the heading (currently "h1")

### `:meta_description`

* Default format is `:text`
* Used as the content for the [meta description tag][meta-description]

### `:body`

* Default format is `:govspeak`
* Used to generate the main content (appearing above the start button)

### `:post_body`

* Default format is `:govspeak`
* Used to generate supplementary content (appearing below the start button)

## Example

```erb
<% render_content_for :title do %>
  Look up Meursing code
<% end %>

<% render_content_for :meta_description do %>
  Look up the additional code (Meursing code) required for import or export of goods containing certain types of milk and sugars
<% end %>

<% render_content_for :body do %>
  Use this tool to look up the additional code (Meursing code) for import or export of goods containing certain types of milk and sugars covered Regulation (EC) No. 1216/09.
<% end %>
```

[meta-description]: https://moz.com/learn/seo/meta-description
