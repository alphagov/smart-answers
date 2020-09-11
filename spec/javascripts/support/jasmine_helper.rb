# Use this file to set/override Jasmine configuration options
# You can remove it if you don't need it.
# This file is loaded *after* jasmine.yml is interpreted.
#
# Example: using a different boot file.
# Jasmine.configure do |config|
#    config.boot_dir = '/absolute/path/to/boot_dir'
#    config.boot_files = lambda { ['/absolute/path/to/boot_dir/file.js'] }
# end
#
# Example: prevent PhantomJS auto install, uses PhantomJS already on your path.

require "jasmine/runners/selenium"
require "webdrivers/chromedriver"

Jasmine.configure do |config|
  config.prevent_phantom_js_auto_install = true

  config.runner = lambda { |formatter, jasmine_server_url|
    options = Selenium::WebDriver::Chrome::Options.new
    options.headless!
    options.add_argument("--no-sandbox")

    webdriver = Selenium::WebDriver.for(:chrome, options: options)
    Jasmine::Runners::Selenium.new(formatter, jasmine_server_url, webdriver, 50)
  }
end
