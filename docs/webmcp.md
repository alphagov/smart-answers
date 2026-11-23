# WebMCP

[WebMCP][] lets a web page give AI agents in the browser named functions,
known as tools, each with a description and a JSON Schema for its input and
output. The tools run in the page's own JavaScript, in the user's browser
session. It is a W3C Community Group draft and is currently only available in
Chrome behind a flag.

Smart Answers has an experimental WebMCP integration. It is off unless the
`WEBMCP_ENABLED` environment variable is set.

## How it works

Each flow's start, question and result pages register one tool, named after
the flow (for example `calculate_statutory_sick_pay`). The index page, `/`,
registers `find_smart_answer`, which lists every flow and opens the start page
of the one the agent picks.

A flow's tool calls `GET /:id/step` with the answers the agent knows, keyed by
question name. A question name's final `?` is written as `_q`, as some model
APIs refuse `?` in property names, so `first_sick_day?` is sent as
`first_sick_day_q`. The answers can be in any order and the endpoint returns
either:

- the next question, which the agent can't answer from what it has sent, with
  its wording and an [MCP elicitation][] schema it can use to ask the user
- the outcome as plain text, cut to 6,000 characters, with a link to the
  result page

The reply also lists the answers the route used (`answered`) and those it
hasn't used yet (`unused`) so the agent can keep sending them.

For example:

```
GET /calculate-statutory-sick-pay/step?is_your_employee_getting_q=none&employee_tell_within_limit_q=yes
```

Flows that use the session store don't have a tool or a step endpoint, as that
store is intended for sensitive answers.

The code for this is:

- [`StepPresenter`](../app/presenters/step_presenter.rb), which builds the step reply
- [`ToolSchemaPresenter`](../app/presenters/tool_schema_presenter.rb), which builds the tools' JSON Schemas from a flow
- [`smart-answer-webmcp.js`](../app/assets/javascripts/modules/smart-answer-webmcp.js) and [`smart-answer-webmcp-finder.js`](../app/assets/javascripts/modules/smart-answer-webmcp-finder.js), which register the tools

See [running the WebMCP demo](tasks/webmcp-demo.md) to try it with an agent.

## What WebMCP can be used for

These are the use cases WebMCP's own sources name: Chrome's
[When to use WebMCP][] guide, the [explainer][] and the [spec][WebMCP].

| Use case | Their example | Smart Answers |
| --- | --- | --- |
| [Help users filter information][When to use WebMCP] | A `search_hotels` tool finds hotels in Berlin | **Implemented.** The agent sends the facts it knows and gets the outcome |
| [Help users fill in forms][When to use WebMCP] | Tools submit a timesheet, a warranty claim or a catering request | **Partly.** A tool per question page would add little, as each page is already one labelled question |
| [Help users make purchases][When to use WebMCP] and [tailored shopping][] | `search_products` and `add_to_wishlist` for party supplies | **Not applicable.** There is nothing to buy |
| [Creative and graphic design][] | Editing a flyer, then ordering prints | **Not applicable.** There is nothing to create |
| [Human-in-the-loop workflows][explainer goals] | User and agent share one page, and the user stays in control | **Not implemented.** The tool could move the page to the question it returns, so the user can watch and take over |
| [Specialized developer workflows][] | Reading trybot failures during code review | **Not implemented.** A debugging tool could return the flow graph that `/:id/y/visualise` draws |
| [Assistive technology][WebMCP intro] | Assistive tools call the page's tools | **Not implemented.** No assistive tools that call WebMCP were found |
| [Tools from an embedded page][] | A host page calls an embedded widget's tools | **Not applicable.** Smart answers aren't embedded in other sites |

The explainer's [non-goals][] include headless browsing and replacing backend
integrations.

[WebMCP]: https://webmachinelearning.github.io/webmcp
[WebMCP intro]: https://webmachinelearning.github.io/webmcp#intro
[MCP elicitation]: https://modelcontextprotocol.io/specification/2026-07-28/client/elicitation
[When to use WebMCP]: https://developer.chrome.com/docs/ai/webmcp/use-cases
[explainer]: https://github.com/webmachinelearning/webmcp#use-cases
[explainer goals]: https://github.com/webmachinelearning/webmcp#goals
[tailored shopping]: https://github.com/webmachinelearning/webmcp#e-commerce--tailored-shopping
[Creative and graphic design]: https://github.com/webmachinelearning/webmcp#creative--graphic-design
[Specialized developer workflows]: https://github.com/webmachinelearning/webmcp#specialized-developer-workflows
[Tools from an embedded page]: https://webmachinelearning.github.io/webmcp#in-page-cross-origin-exposure
[non-goals]: https://github.com/webmachinelearning/webmcp#non-goals
