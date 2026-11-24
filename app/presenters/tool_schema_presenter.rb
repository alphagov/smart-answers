class ToolSchemaPresenter
  JSON_SCHEMA = "https://json-schema.org/draft/2020-12/schema".freeze

  OUTPUT_SCHEMA = {
    "$schema": JSON_SCHEMA,
    type: "object",
    description: "One step of a smart answer: the next question, or the outcome.",
    properties: {
      status: {
        enum: %w[question outcome],
        description: "question: answer it and call again. outcome: stop.",
      },
      node: {
        type: "string",
        description: "The question's name, which is also its answer key, or the outcome's name.",
      },
      answered: {
        type: "array",
        items: { type: "string" },
        description: "Answers this route used. Send them again on your next call.",
      },
      unused: {
        type: "array",
        items: { type: "string" },
        description: "Answers you sent that this route hasn't used. Keep sending them: a later question may need them. " \
                     "Keys that aren't question names also appear here; don't send them again.",
      },
      url: {
        type: "string",
        format: "uri-reference",
        description: "The page a person would reach with these answers. The browser opens it after the call, " \
                     "so the user can see the question or result.",
      },
    },
    required: %w[status node answered unused url],
    oneOf: [
      {
        properties: {
          status: { const: "question" },
          message: {
            type: "string",
            description: "The question as the user would see it, with any dates worked out from earlier answers.",
          },
          requestedSchema: {
            type: "object",
            description: "A JSON Schema for this one answer, in MCP elicitation form. " \
                         "Answer from what you know, or show it to the user as a form.",
          },
          error: {
            type: %w[string null],
            description: "Why your last answer to this question was rejected, or null.",
          },
        },
        required: %w[message requestedSchema error],
      },
      {
        properties: {
          status: { const: "outcome" },
          title: {
            type: "string",
            description: "The outcome's heading.",
          },
          body: {
            type: "string",
            description: "The outcome as plain text, including next steps.",
          },
          truncated: {
            type: "boolean",
            description: "True if body was cut. The full text is at url.",
          },
        },
        required: %w[title body truncated],
      },
    ],
  }.freeze

  FINDER_INPUT_SCHEMA = {
    type: "object",
    properties: {
      slug: {
        type: "string",
        description: "A flow's slug from the list. Leave it out to get the list.",
      },
    },
    additionalProperties: false,
  }.freeze

  FINDER_OUTPUT_SCHEMA = {
    type: "object",
    properties: {
      flows: {
        type: "array",
        description: "Every smart answer on this site, in slug order.",
        items: {
          type: "object",
          properties: {
            slug: {
              type: "string",
              description: "The flow's id, such as calculate-statutory-sick-pay.",
            },
            title: {
              type: "string",
              description: "The flow's title.",
            },
            description: {
              type: "string",
              description: "One line on what the flow answers.",
            },
            url: {
              type: "string",
              format: "uri-reference",
              description: "The flow's start page. Open it to get the flow's own tool.",
            },
          },
          required: %w[slug title description url],
        },
      },
      opened: {
        type: "string",
        format: "uri-reference",
        description: "The start page now opening. Use the tool it registers.",
      },
    },
    oneOf: [{ required: %w[flows] }, { required: %w[opened] }],
  }.freeze

  def initialize(flow)
    @flow = flow
  end

  def answer_key(name)
    name.to_s.sub(/\?\z/, "_q")
  end

  def node_name(key)
    @node_names ||= (@flow.questions.map(&:name) + @flow.additional_parameters).index_by { |name| answer_key(name) }
    @node_names[key]
  end

  def input_schema
    properties = @flow.questions.to_h { |question| [answer_key(question.name), input_property(question)] }
    @flow.additional_parameters.each { |name| properties[answer_key(name)] = { type: "string" } }

    {
      "$schema": JSON_SCHEMA,
      type: "object",
      description: "Answers you already know, keyed by question name. Send {} to get the first question.",
      properties:,
      additionalProperties: false,
    }
  end

  def requested_schema(question_presenter)
    key = answer_key(question_presenter.node_name)

    {
      type: "object",
      properties: { key => requested_property(question_presenter) },
      required: [key],
    }
  end

private

  def input_property(question)
    case question
    when SmartAnswer::Question::Checkbox
      {
        type: "array",
        items: { enum: question.option_keys },
        uniqueItems: true,
        description: question.none_option? ? "Pick any that apply, or [\"none\"] on its own." : "Pick any that apply.",
      }
    when SmartAnswer::Question::Radio
      { type: "string", enum: question.option_keys }
    when SmartAnswer::Question::CountrySelect
      { type: "string", description: "A country slug, such as france or usa." }
    when SmartAnswer::Question::Date
      { type: "string", format: "date" }
    when SmartAnswer::Question::Year
      { type: "string", pattern: "^[0-9]{4}$", description: "A year, such as 2025." }
    when SmartAnswer::Question::Money
      { type: "string", description: "Amount in pounds, such as 4000 or 250.50." }
    when SmartAnswer::Question::Salary
      {
        type: "string",
        pattern: "^[0-9.]+-(week|month|year)$",
        description: "Amount in pounds and how often, such as 500-week, 2000-month or 30000-year.",
      }
    when SmartAnswer::Question::Postcode
      { type: "string", description: "A full UK postcode, such as SW1A 2AA." }
    when SmartAnswer::Question::Value
      { type: "string", description: "A number or text." }
    end
  end

  def requested_property(question_presenter)
    property = input_property(@flow.node(question_presenter.node_name)).except(:enum, :pattern, :uniqueItems)
    options = question_presenter.options.map { |option| { const: option[:value], title: option[:label] } }

    if property[:type] == "array"
      property[:items] = { anyOf: options }
    elsif options.any?
      property[:oneOf] = options
    end

    hint = Nokogiri::HTML::DocumentFragment.parse(question_presenter.hint).text.strip if question_presenter.hint
    description = [hint, property[:description]].compact_blank.join(" ")
    property[:description] = description if description.present?
    property
  end
end
