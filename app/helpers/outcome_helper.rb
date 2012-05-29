module OutcomeHelper
  def mustache_partial(template,context)
    filepath = "#{Rails.root}/app/views/smart_answers/#{template}.mustache"
    Mustache.render(File.read(filepath), context).html_safe
  end

  def mustache_direct(template)
    filepath = "#{Rails.root}/app/views/smart_answers/#{template}.mustache"
    File.read(filepath).html_safe
  end

  def prettify_contact(contact)
    contact = contact.dup

    # format newlines correctly and remove any double line breaks or trailing line breaks
    contact.gsub!("\n","<br>")
    contact.gsub!("<br>,","<br>")
    contact.gsub!(/,$/,"")
    contact.gsub!(/(<br>\s?)+/,"<br>")
    contact.gsub!(/<br>$/,"")
    contact.gsub!(/\A<br>/,"")

    # strip commas at end of lines
    contact.gsub!(/,$/,"")
    # force space after remaining commas
    contact.gsub!(/,/,", ")

    # highlight the first line
    contact.gsub!(/\A([^\<]+)/,"<strong>\\1</strong>")

    contact
  end
end