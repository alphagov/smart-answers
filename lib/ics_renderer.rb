class ICSRenderer
  def initialize(events, cal_path)
    @events = events
    @cal_path = cal_path
  end

  def render
    output =  "BEGIN:VCALENDAR\r\n"
    output << "VERSION:2.0\r\n"
    output << "METHOD:PUBLISH\r\n"
    output << "PRODID:-//uk.gov/GOVUK smart-answers//EN\r\n"
    output << "CALSCALE:GREGORIAN\r\n"
    @events.each_with_index do |event,i|
      output << render_event(event,i)
    end
    output << "END:VCALENDAR\r\n"
  end

  def render_event(event, sequence)
    output =  "BEGIN:VEVENT\r\n"
    if event.date.is_a?(Range)
      output << "DTEND;VALUE=DATE:#{ event.date.last.strftime("%Y%m%d") }\r\n"
      output << "DTSTART;VALUE=DATE:#{ event.date.first.strftime("%Y%m%d") }\r\n"
    else
      output << "DTEND;VALUE=DATE:#{ event.date.strftime("%Y%m%d") }\r\n"
      output << "DTSTART;VALUE=DATE:#{ event.date.strftime("%Y%m%d") }\r\n"
    end
    output << "SUMMARY:#{ event.title }\r\n"
    output << "UID:#{uid(sequence)}\r\n"
    output << "SEQUENCE:0\r\n"
    output << "DTSTAMP:#{dtstamp}\r\n"
    output << "END:VEVENT\r\n"
  end

  def uid(sequence)
    @path_hash ||= Digest::MD5.hexdigest(@cal_path)
    "#{@path_hash}-#{sequence}@gov.uk"
  end

  def dtstamp
    unless @dtstamp
      time = File.mtime( Rails.root.join('REVISION') ) rescue Time.now
      @dtstamp = time.utc.strftime("%Y%m%dT%H%M%SZ")
    end
    @dtstamp
  end
end
