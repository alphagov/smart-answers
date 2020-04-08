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

