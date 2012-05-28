# encoding: UTF-8

module SmartAnswerTestHelper
  def expect_question(question_substring)
    begin
      wait_until { has_question?(question_substring) }
      assert_match question_regexp(question_substring), actual_question_text
    rescue Capybara::TimeoutError
      raise "Expected question '#{question_substring}', but found '#{actual_question_text}'"
    end
  end

  def actual_question_text
    normalize_whitespace(page.find('.current-question h2').text)
  rescue Capybara::ElementNotFound
    nil
  end

  def normalize_whitespace(html_text)
    html_text.gsub(/\s+/, ' ')
  end

  def has_question?(question_substring)
    !! question_regexp(question_substring).match(actual_question_text)
  end

  def question_regexp(question_substring)
    quoted = Regexp.quote(normalize_whitespace(question_substring))
    quoted_with_ellipsis_as_wildcard = quoted.gsub(Regexp.quote('...'), ".*")
    Regexp.new(quoted_with_ellipsis_as_wildcard)
  end

  def respond_with(value)
    if page.has_css?("select[name='response[period]']")
      fill_in "response[amount]", with: value[:amount]
      select value[:period], from: "response[period]"
    elsif page.has_css?("input[name=response][type=radio]")
      choose value
    elsif page.has_css?("select[name='response[day]']")
      date = Date.parse(value.to_s)
      select date.day.to_s, from: "response[day]"
      select date.strftime('%B'), from: "response[month]"
      select date.year.to_s, from: "response[year]"
    elsif page.has_css?("input[name=response][type=text]")
      fill_in "response", with: value
    elsif page.has_css?("select[name='response']")
      select value, from: "response"
    end
    click_next_step
  end

  def click_next_step
    click_on "Next step"
  end

  def format(date)
    Date.parse(date.to_s).strftime('%e %B %Y')
  end

  def assert_results_contain(string)
    within '.results' do
      assert page.has_content?(string)
    end
  end
end
