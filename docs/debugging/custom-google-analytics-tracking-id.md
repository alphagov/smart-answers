# Custom Google Analytics account and Tracking ID

This describes how to record data in a different Google Analytics account. This can be useful when testing Google Analytics integration to ensure that things are working as expected.

## Custom Tracking ID

You'll need your own Google Analytics account and to have created a Tracking ID for Smart Answers. Creating these is outside the scope of this guide.

## Running Static locally

You'll need to have a copy of [Static][static-repository] running locally. Smart Answers expects to find your local copy of Static at [http://static.dev.gov.uk][static-dev]. You can change this by setting the `PLEK_SERVICE_STATIC_URI` environment variable.

## Using your custom Tracking ID

Open your copy of Static and replace the `universalId` variable in [analytics/init.js][static-universal-id] with your Tracking ID.

## Testing that it works

Open your Google Analytics account and visit the Real Time > Overview report. Visit your local copy of Smart Answers and observe the activity in Google Analytics.

## Debugging

The [Google Analytics Debugger Chrome extension][ga-debugger] can be useful when trying to understand why you're not seeing the data you expect in Google Analytics.

[ga-debugger]: https://chrome.google.com/webstore/detail/google-analytics-debugger/jnkmfdileelhofjcijamephohjechhna?hl=en
[static-dev]: http://static.dev.gov.uk
[static-repository]: https://github.com/alphagov/static
[static-universal-id]: https://github.com/alphagov/static/blob/059f6a534b595c543852c25ced151019b2b6cd72/app/assets/javascripts/analytics/init.js#L13
