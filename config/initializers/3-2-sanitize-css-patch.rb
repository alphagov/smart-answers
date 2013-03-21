# [CVE-2013-1855] XSS vulnerability in sanitize_css in Action Pack
#
# Link: https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/4_QHo4BqnN8
if Rails.version == "3.2.12"
  module HTML
    class WhiteListSanitizer
      # Sanitizes a block of css code. Used by #sanitize when it comes across a style attribute
      def sanitize_css(style)
        # disallow urls
        style = style.to_s.gsub(/url\s*\(\s*[^\s)]+?\s*\)\s*/, ' ')

        # gauntlet
        if style !~ /\A([:,;#%.\sa-zA-Z0-9!]|\w-\w|\'[\s\w]+\'|\"[\s\w]+\"|\([\d,\s]+\))*\z/ ||
            style !~ /\A(\s*[-\w]+\s*:\s*[^:;]*(;|$)\s*)*\z/
          return ''
        end

        clean = []
        style.scan(/([-\w]+)\s*:\s*([^:;]*)/) do |prop,val|
          if allowed_css_properties.include?(prop.downcase)
            clean <<  prop + ': ' + val + ';'
          elsif shorthand_css_properties.include?(prop.split('-')[0].downcase)
            unless val.split().any? do |keyword|
                !allowed_css_keywords.include?(keyword) &&
                  keyword !~ /\A(#[0-9a-f]+|rgb\(\d+%?,\d*%?,?\d*%?\)?|\d{0,2}\.?\d{0,2}(cm|em|ex|in|mm|pc|pt|px|%|,|\))?)\z/
              end
              clean << prop + ': ' + val + ';'
            end
          end
        end
        clean.join(' ')
      end
    end
  end
end
