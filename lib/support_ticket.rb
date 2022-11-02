require "gds_zendesk/client"
require "gds_zendesk/dummy_client"
class SupportTicket
  REQUESTER = {
    name: "Smart Answers application",
  }.freeze

  TAGS = ["broken links"].freeze

  PRIORITY = "normal".freeze

  def self.client
    @client ||= if Rails.env.development?
                  GDSZendesk::DummyClient.new(logger: Rails.logger)
                else
                  credentials = ZENDESK_CREDENTIALS.merge(logger: Rails.logger)
                  GDSZendesk::Client.new credentials
                end
  end

  def self.send(subject:, body:, requester_email:)
    new(subject:, body:, requester_email:).send
  end

  attr_reader :subject, :body, :requester_email

  def initialize(subject:, body:, requester_email:)
    @subject = subject
    @body = body
    @requester_email = requester_email
  end

  def payload
    {
      subject:,
      priority: PRIORITY,
      requester: REQUESTER.merge(email: requester_email),
      tags: TAGS,
      comment: { body: },
    }
  end

  def send
    self.class.client.zendesk_client.tickets.create!(payload)
  end
end
