# How to retire a Smart Answer

At some point a request might come in for the removal of a SmartAnswer, most likely this request will include redirecting paths belonging to the identified smart answer to a new destination.

In this document is prescribed the steps that need to be taken:

- Remove the identified smart answer:

  Remove all data, YAML, test artefacts, templates and code that belong
  to the identified smart answers. After this is done, it is very
  necessary to run the unit, integration and regression tests. It is
  important that you run these tests on local and in integration
  environments. If these tests pass, then proceed to the next steps.

- Unpublish the identified smart answer:

  To unpublish, the publishing_api:unpublish rake task needs to be run.

  This needs to be supplied with the content id belonging to the
  identified smart answer. The content id can be found in the flow class
  for the smart answer.

  (i.e `rake publishing_api:unpublish[content-id]`)

  This updates the edition of a document into an unpublished state. The
  edition will be updated and removed from the live content store and
  sets it to type of gone with status 410.

  This uses the publishing-api to un-publish the given smart answer.

- Redirect smart answer paths to new destination:

  To redirect, the publishing_api:redirect_smart_answer rake task needs
  to be run.

  For this task to run, it needs to be supplied the smart answer's
  base_path and the new destination.

  (i.e `rake publishing_api:redirect_smart_answer[path,destination]`)

  When this rake task is invoked, a new redirect draft edition is
  created and published.

- Manually updating segments mode (optional):

  Ideally, the rake tasks and calls to the publishing-api should be enough to
  retire and redirect a content item. For some unknown reasons, this process may
  require the manual update (i.e segments_mode property) of the Route record
  for the smart answer path.

  This can be achieved through the rails console for the router-api app.

  **NB:**
  Login to rails console for router-api

  ```bash
    govuk_app_console router-api
  ```

  And then:

  ```ruby
    route = Route.find_by(incoming_path: "/smart-answer-base-path")
    route.segments_mode = "ignore"
    route.save!
    RouterReloader.reload
  ```

- Remove smart answer content from search index:

  In order to remove the identified smart answer's content from the
  search index, the following rake task needs to be run.

  (i.e `rake rummager:remove_smart_answer_from_search[base_path]`)

  After running this task, the smart answer should no longer be
  discoverable via search.

- Reseting cache (optional):

  After rake tasks have been run, it may be important to clear the cache for the smart answer in question.

  These fabricator tasks are required:
  - `production cache.purge:"/smart-answer-base-path"`
  - `production cdn.purge_all:"/smart-answer-base-path"`
