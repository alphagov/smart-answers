# Landing page template

Landing page templates live in `lib/smart_answer_flows/<flow-name>/<flow-name-with-underscores>.govspeak.erb`.

The templates can contain content for the `title`, `meta_description`, `body` and `post_body`, all of which are optional.

## Example

```
<% content_for :title do %>
  Look up Meursing code
<% end %>

<% content_for :meta_description do %>
  Look up the additional code (Meursing code) required for import or export of goods containing certain types of milk and sugars
<% end %>

<% content_for :body do %>
  Use this tool to look up the additional code (Meursing code) for import or export of goods containing certain types of milk and sugars covered Regulation (EC) No. 1216/09.
<% end %>
```
