# encoding: utf-8
require_relative '../test_helper'
require 'ics_renderer'

class ICSRendererTest < ActiveSupport::TestCase

  context "generating complete ics file" do
    should "generate correct ics header and footer" do
      r = ICSRenderer.new([], "/foo/ics")

      expected =  "BEGIN:VCALENDAR\r\n"
      expected << "VERSION:2.0\r\n"
      expected << "METHOD:PUBLISH\r\n"
      expected << "PRODID:-//uk.gov/GOVUK smart-answers//EN\r\n"
      expected << "CALSCALE:GREGORIAN\r\n"
      expected << "END:VCALENDAR\r\n"

      assert_equal expected, r.render
    end

    should "generate an event for each given event" do
      r = ICSRenderer.new([:e1, :e2], "/foo/ics")
      r.expects(:render_event).with(:e1, 0).returns("Event1 ics\r\n")
      r.expects(:render_event).with(:e2, 1).returns("Event2 ics\r\n")

      expected =  "BEGIN:VCALENDAR\r\n"
      expected << "VERSION:2.0\r\n"
      expected << "METHOD:PUBLISH\r\n"
      expected << "PRODID:-//uk.gov/GOVUK smart-answers//EN\r\n"
      expected << "CALSCALE:GREGORIAN\r\n"
      expected << "Event1 ics\r\n"
      expected << "Event2 ics\r\n"
      expected << "END:VCALENDAR\r\n"

      assert_equal expected, r.render
    end
  end

  context "generating an event" do
    setup do
      @r = ICSRenderer.new([], "/foo/ics")
      ICSRenderer.any_instance.stubs(:dtstamp).returns("20121017T0100Z")
    end

    should "render an event with a date" do
      e = OpenStruct.new("title" => "An Event", "date" => Date.parse("2012-04-14") )

      @r.expects(:uid).with(2).returns("sdaljksafd-2@gov.uk")

      expected =  "BEGIN:VEVENT\r\n"
      expected << "DTEND;VALUE=DATE:20120415\r\n"
      expected << "DTSTART;VALUE=DATE:20120414\r\n"
      expected << "SUMMARY:An Event\r\n"
      expected << "UID:sdaljksafd-2@gov.uk\r\n"
      expected << "SEQUENCE:0\r\n"
      expected << "DTSTAMP:20121017T0100Z\r\n"
      expected << "END:VEVENT\r\n"

      assert_equal expected, @r.render_event(e, 2)
    end

    should "render an event with a range" do
      e = OpenStruct.new("title" => "An Event", "date" => Date.parse("2012-04-14")..Date.parse("2012-04-18") )

      @r.expects(:uid).with(2).returns("sdaljksafd-2@gov.uk")

      expected =  "BEGIN:VEVENT\r\n"
      expected << "DTEND;VALUE=DATE:20120419\r\n"
      expected << "DTSTART;VALUE=DATE:20120414\r\n"
      expected << "SUMMARY:An Event\r\n"
      expected << "UID:sdaljksafd-2@gov.uk\r\n"
      expected << "SEQUENCE:0\r\n"
      expected << "DTSTAMP:20121017T0100Z\r\n"
      expected << "END:VEVENT\r\n"

      assert_equal expected, @r.render_event(e, 2)
    end

  end

  context "generating a uid" do
    setup do
      @r = ICSRenderer.new([], "/foo/bar.ics")
    end

    should "use the calendar path, and sequence to create a uid" do
      hash = Digest::MD5.hexdigest("/foo/bar.ics")
      assert_equal "#{hash}-2@gov.uk", @r.uid(2)
    end

    should "cache the hash generation" do
      Digest::MD5.expects(:hexdigest).with("/foo/bar.ics").once.returns("hash")
      @r.uid(1)
      assert_equal "hash-2@gov.uk", @r.uid(2)
    end
  end

  context "generating dtstamp" do
    setup do
      @r = ICSRenderer.new([], "/foo/ics")
    end

    should "return the mtime of the REVISION file" do
      File.expects(:mtime).with(Rails.root.join("REVISION")).returns(Time.parse('2012-04-06 14:53:54'))
      assert_equal "20120406T145354Z", @r.dtstamp
    end

    should "return now if the file doesn't exist" do
      Timecop.freeze(Time.parse('2012-11-27 16:13:27')) do
        File.expects(:mtime).with(Rails.root.join("REVISION")).raises(Errno::ENOENT)
        assert_equal "20121127T161327Z", @r.dtstamp
      end
    end

    should "cache the result" do
      File.expects(:mtime).with(Rails.root.join("REVISION")).once.returns(Time.parse('2012-04-06 14:53:54'))
      @r.dtstamp
      assert_equal "20120406T145354Z", @r.dtstamp
    end
  end
end
