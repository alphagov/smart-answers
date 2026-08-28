module SelectiveWarningFilter
  def warn(message, category: nil, **kwargs)
    msg = message.to_s

    if msg.include?("literal string will be frozen in the future") && msg.include?("govspeak.rb")
      return
    end

    if msg.include?("parser/current is loading parser/") && msg.include?("recognizes")
      return
    end

    super
  end
end

Warning.extend(SelectiveWarningFilter)

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
