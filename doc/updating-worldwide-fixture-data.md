# Updating Worldwide fixture data

Ideally, we'll keep both the location and organisation data up to date but there's nothing prompting us to do that at the moment.

You should ensure you run all the tests, including all the regression tests, after updating this data.

## Worldwide locations

Update the worldwide location fixture data using:

```bash
$ rails r script/update-world-locations.rb
```

## Worldwide organisations

Update the worldwide organisations fixture data using:

```bash
$ rails r script/update-worldwide-location-organisations.rb
```
