## Retirement log

- Overseas passports
  - Date of retirement: [28/04/2017](https://github.com/alphagov/smart-answers/releases/tag/release_3562).
  - Associated [pull request](https://github.com/alphagov/smart-answers/pull/3014)
  - Start button text set to external link: https://www.passport.service.gov.uk/filter.
  - Changed format of start page on `/overseas-passports` to an answer format.
  - Redirects from `/overseas-passports/y` to `/overseas-passports`.
  - Artefact on publisher has been archived and it's slug changed to `archived-overseas-passports`.

- State pension top up
  - Date of retirement:  [06/04/2017](https://github.com/alphagov/smart-answers/releases/tag/release_3549)
  - Associated [pull request](https://github.com/alphagov/smart-answers/pull/2996)
  - Redirects from `/state-pension-topup` (and all descendants i.e `/state-pension-topup/\*`) to `/state-pension-top-up`
  - Artefact on publisher remains unchanged.

- PIP Checker
  - Date of retirement:  [22/06/2017](https://github.com/alphagov/smart-answers/releases/tag/release_3626)
  - Associated [pull request](https://github.com/alphagov/smart-answers/pull/3035)
  - Redirects from `/pip-checker` (and all descendants i.e `/pip-checker/\*`) to `/pip`
  - Artefact on publisher remains unchanged.

- Legalisation document Checker
  - Date of retirement:  [01/08/2017](https://github.com/alphagov/smart-answers/releases/tag/release_3690)
  - Associated [pull request](https://github.com/alphagov/smart-answers/pull/3163)
  - Redirects from `/legalisation-document-checker` (and all descendants i.e `/legalisation-document-checker/\*`) to `/get-document-legalised`
    - This is the first retirement post the [splitting of the start pages from the rest of the flow](https://github.com/alphagov/smart-answers/pull/3126). So the retiring rake task is different and should be use onward.
    ```ruby
      retire:unpublish_redirect_remove_from_search[86acf061-f878-4da1-b05b-80c7ef61305c,/legalisation-document-checker,/get-document-legalised]
      retire:unpublish[3f1673a7-62b5-4ea0-883d-faa602e7f6a9]
      retire:publish_redirect[/legalisation-document-checker/y,/get-document-legalised]
    ```
  - Artefact on publisher remains unchanged.
