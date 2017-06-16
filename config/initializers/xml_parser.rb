# Turn off XML parsing:
# https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ/discussion
ActionDispatch::Http::Parameters::DEFAULT_PARSERS.delete(Mime[:xml])
