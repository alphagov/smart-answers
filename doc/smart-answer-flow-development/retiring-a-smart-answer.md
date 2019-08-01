# How to retire a Smart Answer

At some point a request might come in for the removal of a SmartAnswer, most likely this request will include redirecting paths belonging to the identified smart answer to a new destination or retain the start page of the smart answer.

> *Note:* It is important to bear in mind that a smart answer comprises of two
> main content items, the start page and the flow. These two need to be retired.

In this document is prescribed the steps that need to be taken:

- ## Remove the identified smart answer:

  Remove the following files/directory where possible:
    - Flow class files
      - lib/smart_answer_flows/<\smart-answer-name>.rb
    - ERB templates directory
      - lib/smart_answer_flows/<\smart-answer-name>
    - YAML files
      - lib/data/rates/<\smart-answer-name>.yml
      - lib/data/<\smart-answer-name>.yml
    - Tests for Calculators, rates, data query and other ruby files
      - test/integration/calculators/<\smart-answer-name>_(calculator|rates_query|data_query)_test.rb
      - test/integration/smart_answer_flows/<\smart-answer-name>_test.rb
      - test/unit/calculators/<\smart-answer-name>_(calculator|rates_query|data_query)_test.rb
      - test/unit/calculators/smart_answer_flows/<\smart-answer-name>_flow_test.rb
    - Calculators, data query and other ruby files
      - lib/smart_answer/calculators/<\smart-answer-name>_calculator.rb
      - lib/smart_answer/calculators/<\smart-answer-name>_data_query.rb

  After this is done, it is very necessary to run the unit and integration tests.
  It is important that you run these tests on local and in
  integration environments. If these tests pass, then proceed to the next steps.

- ## Retire and redirect the identified smart answer:

  To retire a smart answer and redirect the base_path of to a new destination,
  the retire smart answer rake task is available. It needs to be supplied a
  content-id, base_path and it's new destination.

  (i.e `retire:unpublish_redirect_remove_from_search[content_id,base_path,destination]`)

  The content-id for a smart answer can be found in the flow class for the smart
  answer in question. Also it can be found via the content store using the
  GOV.UK chrome extension.

  The base_path is the path belonging to the smart answer and very likely
  associated with the name of the smart_answer defined in the flow class.

  The destination is the path where this base_path of the smart asnwer should redirect to. This could be a path to a new flat content etc.

  Below is a break down of steps that make up this process.

  - ### Unpublish the identified smart answer:

    This updates the edition of a document into an unpublished state. The
    edition will be updated and removed from the live content store and
    sets it to type of gone with status 410.

    This is done via publishing-api.

  - ### Redirect smart answer paths to new destination:

    This unpublishes the Smart Answer, using a redirect to the
    destination specified and segments_mode set to ignore.

  - ### Remove smart answer content from search index:

    This the smart answer from the search index and after this has been removed
    it should no longer be discoverable via search.

- ## Retire and publish transaction format as start page:

  To retire a smart answer, retain its base_path, start page content and set
  start button link. This can be achieved by running the unpublish and
  publish_transaction rake tasks. unpublish task need to be run first.

  The unpublish rake task needs to be supplied a content-id only.

  (i.e `rake retire:unpublish[content_id]`)

  The publish_transaction rake task needs to be supplied base_path,publishing
  application (i.e publisher, smartanswers etc), title (i.e start page title),
  content (i.e start page description), link (i.e start button link/href).

  (i.e `rake retire:publish_transaction[base_path,publishing_app,title,content,link]`)

  The content-id for a smart answer can be found in the flow class for the smart
  answer in question. Also it can be found via the content store using the
  GOV.UK toolkit chrome extension.

  The base_path is the path belonging to the smart answer and very likely
  associated with the name of the smart_answer defined in the flow class.

  The title and content and link may already exist as part of the start page of the smart answer or could be supplied by the content designer.

  It is worthy of note that the title and content may contain spaces and special
  characters. It is advisable to use back slash to escape these.

  Below is a break down of steps that make up this process.

  - ### Unpublish the identified smart answer:

    This updates the edition of a document into an unpublished state. The
    edition will be updated and removed from the live content store and
    sets it to type of gone with status 410.

    This is done via publishing-api.

    (i.e `rake retire:unpublish[content_id]`)

  - ### Change publishing application

    This changes the reserve publishing application for the base path.
    Use the code below to verify the update.

    ```ruby
      PathReservation.find_by(base_path: "/base-path")
    ```

    This is done via publishing-api.

  - ### Publish transaction:

    This creates and publishes a transaction format edition to be used as the new start page in replace of the smart answer.

    This is done via publishing-api.

- ## Retire and publish answer format as start page:

  To retire a smart answer, retain its base_path and set start page content. This can be achieved by running the unpublish and
  publish_answer rake tasks. unpublish task need to be run first.

  The unpublish rake task needs to be supplied a content-id only.

  (i.e `rake retire:unpublish[content_id]`)

  The publish_answer rake task needs to be supplied base_path,publishing
  application (i.e publisher, smartanswers etc), title (i.e start page title),
  content (i.e start page description), link (i.e start button link/href).

  (i.e `rake retire:publish_answer[base_path,publishing_app,title,content]`)

  The content-id for a smart answer can be found in the flow class for the smart
  answer in question. Also it can be found via the content store using the
  GOV.UK toolkit chrome extension.

  The base_path is the path belonging to the smart answer and very likely
  associated with the name of the smart_answer defined in the flow class.

  The title and content may already exist as part of the start page of the smart answer or could be supplied by the content designer.

  It is worthy of note that the title and content may contain spaces and special
  characters. It is advisable to use back slash to escape these.

  Below is a break down of steps that make up this process.

  - ### Unpublish the identified smart answer:

    This updates the edition of a document into an unpublished state. The
    edition will be updated and removed from the live content store and
    sets it to type of gone with status 410.

    This is done via publishing-api.

    (i.e `rake retire:unpublish[content_id]`)

  - ### Change publishing application

    This changes the reserve publishing application for the base path.
    Use the code below to verify the update.

    ```ruby
      PathReservation.find_by(base_path: "/base-path")
    ```

    This is done via publishing-api.

  - ### Publish answer format:

    This creates and publishes an answer format edition to be used as the new start page in replace of the smart answer.

    This is done via publishing-api.

- ## Retire and publish a simple smart answer:

  After deleting its files from smart-answers ([guide](https://github.com/alphagov/smart-answers/blob/master/doc/retiring-a-smart-answer.md)), the following steps have to be followed to apply the changes to the other applications and on **staging/production environments**:

  **Retire the smart-answer via rake task**
  - go to Jenkins: https://deploy.integration.publishing.service.gov.uk/job/run-rake-task/build?delay=0sec
  - set & run:
    ```
    TARGET_APPLICATION = smartanswers
    MACHINE_CLASS = calculators_frontend
    RAKE_TASK = <rake task name only (no bundle exec rake) …. >
    ```
    ```
    (bundle exec rake) retire:unpublish_with_vanish[67764435-e8ed-4700-a657-2e0432cb1f5b]
    (bundle exec rake) retire:change_owning_application[/student-finance-forms,publisher]
    ```
  Verify success on Publishing API with:
    - SSH to backend: ```ssh publishing-api-1.backend.(integration|staging|production)```
    - rails console: ```govuk_app_console publishing-api```
    - check publishing_app: "publisher" (no more smart-answers) with `PathReservation.find_by(base_path: '/student-finance-forms')`

  **Publish the simple smart answer document with the format manually**
    - Manually archive existing Artefact on publisher storage.
      - SSH to backend: ```ssh backend-1.backend.(integration|staging|production)```
      - rails console: ```govuk_app_console publisher```
      ```
      artefact = Artefact.find_by(slug: "student-finance-forms")
      artefact.state = "archived"
      artefact.save!
      artefact.slug = "archived-student-finance-forms"
      artefact.save!
      ```
    - Publish new simple smart answer for student-finance-forms from publisher
    - Update the retirement log ([link](https://github.com/alphagov/smart-answers/blob/master/doc/retirement-log.md))
