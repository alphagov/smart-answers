# ADR 2: Store responses in query string

## Background

At the time of writing Smart Answer's has two methods of storing user responses: appending to the URL path or saving to the user's session cookie.

The original and most used method is appending responses to the URL path, for example `gov.uk/flow-name/y/response1/response2/response3`. This generates an array of responses that Smart Answers uses to resolves which question or outcome needs to be displayed next. It does so by "replaying" the flow, assuming the responses are in order of which question were previously displayed. No explicit information is stored in the URL about which question each response relates to.

The other method is storing user's responses in session cookies. This functionality was added when we added the `find-coronavirus-support` flow. This flow handled sensitive information that needed to be hidden from the URL. The use of sessions was also required to support the `Leave this site` component, which allowed users to quick erase their responses and prevent them from being recovered. The user responses are stored as a hash keyed by the name of the node (question) which provided the response, for example:

```ruby
session = {
  'flow-name': {
     'question1': 'response1',
     'question2': 'response2',
     'question3': 'response3',
     }
}
```

When Smart Answer's was originally built the use of session was thought to be unnecessary as user data expected to be handled wasn't sensitive. The reasoning for appending to the URL path instead of using a query string is unclear.

## Problem

There are several drawbacks from using the URL path to store user responses:

1. There is no information within the URL to indicate which page the user is requesting. This makes it impossible to understand which page is being displayed to the user, without knowing internal logic of a particular flow. This is problematic for understanding user analytics, request logs and debugging. Our current user analytics determine which page is displayed to a user from content within the page (e.g. heading text). This is fragile as content changes and cumbersome as we have to update our analytics logic when we change the content. As for request logs, there is no easy way to calculate metrics per page as multiple request URLs may resolve to the same page.

1. It is difficult to generate URLs with pre-populate responses, for example `/flow-name/y/response1/response2/<pre-populated-response>`. Unless the response is for the first question in a flow, it requires pre-filling responses for all former questions which are unlikely to be known. 

1. Changes to a flow can cause issues with previously cached pages. As URLs are not deterministic for a particular page, changes to a flow can alter which page is displayed. For example, a given flow displays an outcome page for the path `/x/y/z`. A question is removed and the flow now shows an outcome page for the path `/x/y`. The cache would continue to return the old question and users would then be redirected to `/x/y/z`, which is no longer a valid path and could result in an error if it was not also cached.

1. We lose existing responses if the user visits an earlier question. To view a previous or earlier question, responses need to be removed from the URL. This means that it is impossible to change a previous response without re-answering all subsequent questions. This can be a particular burden for users if the flow is long to complete, requires complex input (e.g. dates) or information that isn't memorised.

Additionally, the implementation of storing user responses in a session required the creation of a seperate controller `SessionAnswersController`, separate logic for node resolution and updating the flow. This adds extra burden when maintaining or improving the codebase, as new code may need to accommodate both response storage methods.

## Proposal

Add the ability to store user responses using the URL query string. This will become the default method for storing responses and replace use of the URL path. The ability to store responses in a session cookie will remain and require flow to explicitly enable it within configuration (current behaviour).

### URL structure

The new structure of URL will be:

`/<flow-name>/flow/<node-id>?<node_id>=<user_response>`

The start page route will remain the same. The node ID `node-id` represent the pre-existing ids in the flow definition:

```ruby
checkbox_question :<node_id> do
  on_response do |response|
  ...
```

Node ids will need to be unique to each node in an individual flow.

Example of routes using query parameters:

- `check-uk-visa/y` => `check-uk-visa/flow/nationality`
- `check-uk-visa/y/australia` => `check-uk-visa/flow/purpose?nationality=australia`
- `check-uk-visa/y/australia/tourism` => `check-uk-visa/flow/result?purpose=tourism&nationality=australia`

### Rename `/s/` prefix to `/flow/`

Whilst not necessary for storing responses in the query string, this is a good oppurtunity to rename the `/s/` prefix slug. This slug was introduced as part of the work to implement session based flows and is thought to stand for "session". This slug will be changed to `/flow/` as routes will be used for query string, not just session based flows. The prefix slug is required due to constraints in the Publishing API that prevent multiple content items (start page and smart answer) having the same base path.

### Remove invalid query parameters
As users navigate throught the flow the only persisted query parameters will be those that are valid for a question in the flow. Any extra query parameters that don't match a question ID will be stripped out.

For example user makes a request to `/check-uk-visa/flow/nationality?random=blah`, which has an extra query parameter of `random=blah`. When they continue to next question Smart Answers redirects them to the following URL `/check-uk-visa/flow/purpose?nationality=australia` with the extra parameter removed.

However, query parameters for valid questions would persist. For example, `/check-uk-visa/flow/nationality?length_of_stay=6_months` -> `/check-uk-visa/flow/purpose?nationality=australia&length_of_stay=6_months`.

### Suggested steps for implementation

To implement this change, we could leverage the existing code (controller, node resolution and flow updates) written for storing responses in a session. This is because the underlying data structure storing the responses is the same i.e. a hash keyed by node name. The only additional logic required is to retrieve and update the parameters in the query string instead from the session.

1. Rename `/s/` route prefix to `/flow/`
    1. Add ability to support `/flow/` prefixed routes for session based flows.
    1. Update start page for session based flows to use `/flow/` prefix routes. 
    1. Add redirects for existing flows with `/s/` routes to their start page.
1. Rename `SessionAnswersController` to `FlowController` (as will be used to handle all flows)
1. Support storing responses in query string and migrate existing flows
    1. Change `use_session` configuration option in flow definition to specify different response store types. e.g. `response_store :session`
    1. Register prefix routes for both `/flow/` and `/y/` for flows that use the URL path to store responses. Note at this point, flows will still store reponses using the URL path and start pages will link to the existing `/y/` routes.
    1. Add functionality to store responses in query string
    1. Add ability to specify config option for query string response store e.g. `response_store :query_string`
    1. Migrate existing flows incrementally to use query string. Update the start page with the link to `/flow/` prefixed routes. Existing links to the `/y/` prefixed routes will continue to work and will store responses using the URL path.
    1. Make query string the default response store for all new flows.
    1. Replace prefix routes for existing flows with `/y/` routes registered with redirects to their start page.
1. Remove deprecated code for storing responses in URL paths.
1. Remove redirects routes if unused.

## Consequences

Our caching effectiveness could be reduced due to different ordering of query parameters. For example, `flow-name/flow/results?q1=r1&q2=r2` and `flow-name/flow/results?q2=r2&q1=r1` would render the same page, however both hit origin. This is somewhat mitigated by sorting the parameters when generating URLs in Smart Answers, so that users are using the same ordering.

Smart Answer responses will have longer URLs, as we'll now encode the node name of each question in the URL. Given that the length limit of a URL is about 2000 characters (varies between browsers, CDN providers, search engines etc), and the average node name and response is 12 characters, we can store around 80 responses in the URL using the query string. This is more than enough for our existing flows, the largest needs to accomodate around 21 responses.
