require "test_helper"
require "gds_zendesk/test_helpers"

class SupportTicketTest < ActiveSupport::TestCase
  include GDSZendesk::TestHelpers

  def subject
    @subject ||= "Ticket Subject"
  end

  def body
    @body ||= "This is some ticket content"
  end

  def email
    @email ||= "someone@example.com"
  end

  def support_ticket
    @support_ticket ||= SupportTicket.new(subject:, body:, requester_email: email)
  end

  context ".send" do
    should "sends input via instance" do
      self.valid_zendesk_credentials = ZENDESK_CREDENTIALS
      stub_zendesk_ticket_creation(support_ticket.payload)

      assert SupportTicket.send subject:, body:, requester_email: email
    end
  end

  context "#send" do
    should "sends payload to gov uk zendesk" do
      self.valid_zendesk_credentials = ZENDESK_CREDENTIALS
      stub_zendesk_ticket_creation(support_ticket.payload)

      assert support_ticket.send
    end
  end

  context "#payload" do
    should "include body" do
      assert_equal body, support_ticket.payload.dig(:comment, :body)
    end

    should "include subject" do
      assert_equal subject, support_ticket.payload[:subject]
    end

    should "include requester email" do
      assert_equal email, support_ticket.payload.dig(:requester, :email)
    end
  end
end
