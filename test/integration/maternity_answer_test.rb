# encoding: UTF-8
require_relative '../integration_test_helper'

class MaternityAnswerTest < ActionDispatch::IntegrationTest

  def expect_question(question_substring)
    begin
      actual_question = page.find('.current-question h3')
      assert_match question_regexp(question_substring), actual_question.text
    rescue Capybara::ElementNotFound
      assert false, "Expected question '#{question_substring}', but no question found"
    end
  end
  
  def question_regexp(question_substring)
    quoted = Regexp.quote(question_substring)
    quoted_with_ellipsis_as_wildcard = quoted.gsub(Regexp.quote('...'), ".*")
    Regexp.new(quoted_with_ellipsis_as_wildcard)
  end
  
  def self.should_be_entitled_to(outcome)
    should "be entitled to #{outcome}" do
      case outcome
      when :nothing
        assert page.has_content? "Nothing, maybe benefits"
      when :maternity_allowance
        assert page.has_content? "You qualify for maternity allowance"
      when :statutory_maternity_pay
        assert page.has_content? "You qualify for statutory maternity pay"
      else
        raise "Expected outcome '#{outcome}' not known"
      end
    end
  end  
  
  def respond_with(value)
    if page.has_css?("input[name=response][type=text]")
      fill_in "response", with: value
    elsif page.has_css?("input[name=response][type=radio]")
      choose value
    elsif page.has_css?("select[name='response[day]']")
      date = Date.parse(value.to_s)
      select date.day.to_s, from: "response[day]"
      select date.strftime('%B'), from: "response[month]"
      select date.year.to_s, from: "response[year]"
    end
    click_on "Next step →"
  end
  
  def week_containing(date_or_string)
    date = Date.parse(date_or_string.to_s)
    start_of_week = date - date.wday
    start_of_week..(start_of_week + 6.days)
  end
  
  def expected_week_of_childbirth
    raise "@due_date undefined - can't calculate expected_week_of_childbirth without it" unless @due_date
    week_containing(@due_date)
  end
  
  def qualifying_week
    start = expected_week_of_childbirth.first - 15.weeks
    start .. (start + 6.days)
  end
  
  def maternity_allowance_test_period
    start = expected_week_of_childbirth.first - 66.weeks
    finish = expected_week_of_childbirth.first - 1.day
    start .. finish
  end
  
  def format(date)
    Date.parse(date.to_s).strftime('%e %B %Y')
  end

  test "landing page" do
    visit "/maternity"
    assert page.has_no_selector?("meta[name=robots][content=noindex]"), "Should not have meta noindex"
    assert_match /Maternity benefits entitlement/, page.find("#wrapper h1").text
  end

  context "Everybody" do
    setup do
      visit "/maternity"
      click_on "Get started"
    end
    
    should "be asked due date first" do
      expect_question "When is your baby due?"
    end

    should "be asked employment state second" do
      respond_with Date.today + 30.weeks
      expect_question "Are you employed?"
    end
  end
    
  context "Employed person" do
    setup do
      @employed = "Yes"
      visit "/maternity"
      click_on "Get started"
    end
    
    should "be asked about start date third" do
      @due_date = Date.today + 30.weeks
      respond_with @due_date
      respond_with @employed
      expect_question "Did you start your job on or before #{format(qualifying_week.first - 26.weeks)}?"
    end
    
    context "who started 26 weeks before qualifying week" do
      setup { @started_26_weeks_before_qualifying_week = "Yes" }
    
      context "(which is in the future)," do
        setup do
          @due_date = Date.today + 20.weeks
          respond_with @due_date
          respond_with @employed
          respond_with @started_26_weeks_before_qualifying_week
        end
  
        should "be asked if still working in qualifying week" do
          expect_question "Will you still be in the same job on #{format(qualifying_week.first)}?"
        end
        
        context "who will still be working then" do
          setup { respond_with "Yes" }

          should "be asked weekly pay" do
            expect_question "How much are you paid per week?"
          end
          
          context "paid £102 per week" do
            setup { respond_with "102" }
            should_be_entitled_to :statutory_maternity_pay
          end
          
          context "paid £101 per week" do
            setup { respond_with "101" }
            should_be_entitled_to :maternity_allowance
          end
          
          context "paid £30 per week" do
            setup { respond_with "30" }
            should_be_entitled_to :maternity_allowance
          end
          
          context "paid £29 per week" do
            setup { respond_with "29" }
            should_be_entitled_to :nothing
          end
        end

        context "not still working in qualifying week" do
          setup { respond_with "No" }

          should "considering them for maternity allowance, ask if they worked 26 weeks in test period" do
            expect_question "Will you work at least 26 weeks full- or part-time between " \
              "#{format(maternity_allowance_test_period.first)} and " \
              "#{format(maternity_allowance_test_period.last)}"
          end
          
          context "worked 26 weeks in Maternity Allowance test period" do
            setup { respond_with "Yes" }

            should "Ask weekly earnings" do
              expect_question "How much do you earn per week?"
            end
            
            context "Earns £30 per week" do
              setup { respond_with "30" }
              should_be_entitled_to :maternity_allowance
            end

            context "Earns £29 per week" do
              setup { respond_with "29" }
              should_be_entitled_to :nothing
            end
          end
          
          context "did not work 26 weeks in Maternity Allowance test period" do
            setup { respond_with "No" }

            should_be_entitled_to :nothing
          end
        end
      end
      
      context "(which is in the past)," do
        setup do
          @due_date = Date.today + 10.weeks
          respond_with @due_date
          respond_with @employed
          respond_with @started_26_weeks_before_qualifying_week
        end
      
        should "not be asked to confirm employment during qualifying week, skip straight to weekly pay" do
          assert ! page.has_content?("Will you still be in the same job")
          expect_question "How much are you paid per week?"
        end

        context "paid £102 per week" do
          setup { respond_with "102" }
          should_be_entitled_to :statutory_maternity_pay
        end
        
        context "paid £101 per week" do
          setup { respond_with "101" }
          should_be_entitled_to :maternity_allowance
        end
        
        context "paid £30 per week" do
          setup { respond_with "30" }
          should_be_entitled_to :maternity_allowance
        end
        
        context "paid £29 per week" do
          setup { respond_with "29" }
          should_be_entitled_to :nothing
        end
        
      end
    end
    
    context "who started less than 26 weeks before qualifying week" do
      # If they started less than 26 weeks before the qualifying week, they 
      # can't possibly satisfy the 26 week continuous employment requirement,
      # so consider Maternity allowance instead
      setup do
        @due_date = Date.today + 20.weeks
        respond_with @due_date
        respond_with @employed
        respond_with "No"
      end
      
      should "ask if they worked 26 weeks in test period" do
        expect_question "Will you work at least 26 weeks...between " \
          "#{format(maternity_allowance_test_period.first)} and " \
          "#{format(maternity_allowance_test_period.last)}"
      end
      
      context "worked 26 weeks in Maternity Allowance test period" do
        setup { respond_with "Yes" }

        should "Ask weekly earnings" do
          expect_question "How much do you earn per week?"
        end
        
        context "Earns £30 per week" do
          setup { respond_with "30" }
          should_be_entitled_to :maternity_allowance
        end

        context "Earns £29 per week" do
          setup { respond_with "29" }
          should_be_entitled_to :nothing
        end
      end
      
      context "did not work 26 weeks in Maternity Allowance test period" do
        setup { respond_with "No" }

        should_be_entitled_to :nothing
      end
    end
  end
  
  context "Self- or un-employed person" do
    setup do
      visit "/maternity"
      click_on "Get started"
      @due_date = Date.today + 30.weeks
      respond_with @due_date
      respond_with "No"
    end
    
    should "considering them for maternity allowance, ask if they worked 26 weeks in test period" do
      expect_question "Will you work at least 26 weeks...between " \
        "#{format(maternity_allowance_test_period.first)} and " \
        "#{format(maternity_allowance_test_period.last)}"
    end
    
    context "worked 26 weeks in Maternity Allowance test period" do
      setup { respond_with "Yes" }

      should "Ask weekly earnings" do
        expect_question "How much do you earn per week?"
      end
      
      context "Earns £30 per week" do
        setup { respond_with "30" }
        should_be_entitled_to :maternity_allowance
      end

      context "Earns £29 per week" do
        setup { respond_with "29" }
        should_be_entitled_to :nothing
      end
    end
    
    context "did not work 26 weeks in Maternity Allowance test period" do
      setup { respond_with "No" }

      should_be_entitled_to :nothing
    end
    
  end
end

