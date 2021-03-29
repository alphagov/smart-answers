module SmartAnswerFlowHelpers
  def start(the_flow:, at:)
    visit "/#{at}"
    ensure_page_has(header: the_flow)
    click_link "Start now"
  end

  def answer(question:, of_type:, with:)
    ensure_page_has(header: question)
    case of_type
    when :radio
      choose with
    when :checkbox
      with = [with] if with.is_a?(String)
      raise "For the `checkbox` type, `with` should be a string or an array" unless with.is_a?(Array)

      with.each do |answer|
        check answer
      end
    when :value
      fill_in "response", with: with
    when :date
      date = Date.parse(with)

      fill_in "response[day]", with: date.day
      fill_in "response[month]", with: date.month
      fill_in "response[year]", with: date.year
    else
      raise "Unknown question type [#{of_type}] - please supply a valid option [:checkbox, :checkboxes, :date, :radio, :value]"
    end
    click_button "Continue"
  end

  def ensure_page_has(header: nil, subheaders: nil, text: nil)
    expect(page).to have_selector("h1", text: header) unless header.nil?

    unless subheaders.nil?
      subheaders = [subheaders] if subheaders.is_a?(String)
      raise "`subheaders` should be a string or an array" unless subheaders.is_a?(Array)

      subheaders.each do |heading|
        expect(page).to have_selector("h2", text: heading)
      end
    end

    expect(page).to have_text(text) unless text.nil?
  end

  def ensure_page_has_question(header: nil, text: nil)
    expect(page).to have_selector("span.govuk-caption-xl.gem-c-title__context", text: header) unless header.nil?

    expect(page).to have_text(text) unless text.nil?
  end
end
