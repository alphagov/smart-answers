# Initialise default GOV.UK date formats
# https://www.gov.uk/guidance/style-guide/a-to-z-of-gov-uk-style#dates
Date::DATE_FORMATS[:govuk] = "%-e %B %Y"
Date::DATE_FORMATS[:day_month] = "%-e %b %Y"
Date::DATE_FORMATS[:weekday_name] = "%A, %-e %B %Y"
Date::DATE_FORMATS[:short] = "%-e %b %Y"
Date::DATE_FORMATS[:db] = "%Y-%m-%d"
