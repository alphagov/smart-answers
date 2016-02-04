require_relative '../../lib/data/state_pension_date_query'
require_relative '../test_helper'

class StatePensionDateQueryTest < ActiveSupport::TestCase

  context 'when female, born between 1 January 1890 and 5 April 1950' do
    should 'return state pension date 60 years from date of birth' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('1 January 1890'), :female), Date.parse('1 January 1890') + 60.years
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1950'), :female), Date.parse('5 April 1950') + 60.years
    end

    should 'return pension credit date 60 years from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('1 January 1890')), Date.parse('1 January 1890') + 60.years
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1950')), Date.parse('5 April 1950') + 60.years
    end

    should 'return bus pass qualification date 60 years from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('1 January 1890')), Date.parse('1 January 1890') + 60.years
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1950')), Date.parse('5 April 1950') + 60.years
    end
  end

  context 'when male, born between 1 January 1890 and 5 December 1953' do
    should 'return state pension date 65 years from date of birth' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('1 January 1890'), :male), Date.parse('1 January 1890') + 65.years
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 December 1953'), :male), Date.parse('5 December 1953') + 65.years
    end

    should 'return pension credit date equal to the state pension date for a female with the same dob' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('1 January 1890')),
        StatePensionDateQuery.state_pension_date(Date.parse('1 January 1890'), :female)
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1953')),
        StatePensionDateQuery.state_pension_date(Date.parse('5 December 1953'), :female)
    end

    should 'return bus pass qualification date equal to the pension credit date' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('1 January 1890')),
        StatePensionDateQuery.pension_credit_date(Date.parse('1 January 1890'))
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 December 1953')),
        StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1953'))
    end
  end

  context 'when female or male, born between 6 October 1954 and 5 April 1960' do
    should 'return state pension date 66 years from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 October 1954'), gender), Date.parse('6 October 1954') + 66.years
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1960'), gender), Date.parse('5 April 1960') + 66.years
      end
    end

    should 'return pension credit date 66 years from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 October 1954')), Date.parse('6 October 1954') + 66.years
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1960')), Date.parse('5 April 1960') + 66.years
    end

    should 'return bus pass qualification date 66 years from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 October 1954')), Date.parse('6 October 1954') + 66.years
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1960')), Date.parse('5 April 1960') + 66.years
    end
  end

  context 'when female or male, born between 6 April 1960 and 5 May 1960' do
    should 'return state pension date 66 years and 1 month from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1960'), gender), Date.parse('6 April 1960') + 66.years + 1.month
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 May 1960'), gender), Date.parse('5 May 1960') + 66.years + 1.month
      end
    end

    should 'return pension credit date 66 years and 1 month from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1960')), Date.parse('6 April 1960') + 66.years + 1.month
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 May 1960')), Date.parse('5 May 1960') + 66.years + 1.month
    end

    should 'return bus pass qualification date 66 years and 1 month from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1960')), Date.parse('6 April 1960') + 66.years + 1.month
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 May 1960')), Date.parse('5 May 1960') + 66.years + 1.month
    end
  end

  context 'when female or male, born between 6 May 1960 and 5 June 1960' do
    should 'return state pension date 66 years and 2 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 May 1960'), gender), Date.parse('6 May 1960') + 66.years + 2.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 June 1960'), gender), Date.parse('5 June 1960') + 66.years + 2.months
      end
    end

    should 'return pension credit date 66 years and 2 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 May 1960')), Date.parse('6 May 1960') + 66.years + 2.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 June 1960')), Date.parse('5 June 1960') + 66.years + 2.months
    end

    should 'return bus pass qualification date 66 years and 2 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 May 1960')), Date.parse('6 May 1960') + 66.years + 2.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 June 1960')), Date.parse('5 June 1960') + 66.years + 2.months
    end
  end

  context 'when female or male, born between 6 June 1960 and 5 July 1960' do
    should 'return state pension date 66 years and 3 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 June 1960'), gender), Date.parse('6 June 1960') + 66.years + 3.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 July 1960'), gender), Date.parse('5 July 1960') + 66.years + 3.months
      end
    end

    should 'return pension credit date 66 years and 3 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 June 1960')), Date.parse('6 June 1960') + 66.years + 3.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 July 1960')), Date.parse('5 July 1960') + 66.years + 3.months
    end

    should 'return bus pass qualification date 66 years and 3 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 June 1960')), Date.parse('6 June 1960') + 66.years + 3.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 July 1960')), Date.parse('5 July 1960') + 66.years + 3.months
    end
  end

  context 'when female or male, born between 6 July 1960 and 5 August 1960' do
    should 'return state pension date 66 years and 4 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 July 1960'), gender), Date.parse('6 July 1960') + 66.years + 4.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 August 1960'), gender), Date.parse('5 August 1960') + 66.years + 4.months
      end
    end

    should 'return pension credit date 66 years and 4 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 July 1960')), Date.parse('6 July 1960') + 66.years + 4.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 August 1960')), Date.parse('5 August 1960') + 66.years + 4.months
    end

    should 'return bus pass qualification date 66 years and 4 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 July 1960')), Date.parse('6 July 1960') + 66.years + 4.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 August 1960')), Date.parse('5 August 1960') + 66.years + 4.months
    end
  end

  context 'when female or male, born between 6 August 1960 and 5 September 1960' do
    should 'return state pension date 66 years and 5 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 August 1960'), gender), Date.parse('6 August 1960') + 66.years + 5.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 September 1960'), gender), Date.parse('5 September 1960') + 66.years + 5.months
      end
    end

    should 'return pension credit date 66 years and 5 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 August 1960')), Date.parse('6 August 1960') + 66.years + 5.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 September 1960')), Date.parse('5 September 1960') + 66.years + 5.months
    end

    should 'return bus pass qualification date 66 years and 5 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 August 1960')), Date.parse('6 August 1960') + 66.years + 5.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 September 1960')), Date.parse('5 September 1960') + 66.years + 5.months
    end
  end

  context 'when female or male, born between 6 September 1960 and 5 October 1960' do
    should 'return state pension date 66 years and 6 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 September 1960'), gender), Date.parse('6 September 1960') + 66.years + 6.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 October 1960'), gender), Date.parse('5 October 1960') + 66.years + 6.months
      end
    end

    should 'return pension credit date 66 years and 6 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 September 1960')), Date.parse('6 September 1960') + 66.years + 6.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 October 1960')), Date.parse('5 October 1960') + 66.years + 6.months
    end

    should 'return bus pass qualification date 66 years and 6 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 September 1960')), Date.parse('6 September 1960') + 66.years + 6.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 October 1960')), Date.parse('5 October 1960') + 66.years + 6.months
    end
  end

  context 'when female or male, born between 6 October 1960 and 5 November 1960' do
    should 'return state pension date 66 years and 7 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 October 1960'), gender), Date.parse('6 October 1960') + 66.years + 7.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 November 1960'), gender), Date.parse('5 November 1960') + 66.years + 7.months
      end
    end

    should 'return pension credit date 66 years and 7 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 October 1960')), Date.parse('6 October 1960') + 66.years + 7.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 November 1960')), Date.parse('5 November 1960') + 66.years + 7.months
    end

    should 'return bus pass qualification date 66 years and 7 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 October 1960')), Date.parse('6 October 1960') + 66.years + 7.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 November 1960')), Date.parse('5 November 1960') + 66.years + 7.months
    end
  end

  context 'when female or male, born between 6 November 1960 and 5 December 1960' do
    should 'return state pension date 66 years and 8 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 November 1960'), gender), Date.parse('6 November 1960') + 66.years + 8.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 December 1960'), gender), Date.parse('5 December 1960') + 66.years + 8.months
      end
    end

    should 'return pension credit date 66 years and 8 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 November 1960')), Date.parse('6 November 1960') + 66.years + 8.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1960')), Date.parse('5 December 1960') + 66.years + 8.months
    end

    should 'return bus pass qualification date 66 years and 8 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 November 1960')), Date.parse('6 November 1960') + 66.years + 8.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 December 1960')), Date.parse('5 December 1960') + 66.years + 8.months
    end
  end

  context 'when female or male, born between 6 December 1960 and 5 January 1961' do
    should 'return state pension date 66 years and 9 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 December 1960'), gender), Date.parse('6 December 1960') + 66.years + 9.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 January 1961'), gender), Date.parse('5 January 1961') + 66.years + 9.months
      end
    end

    should 'return pension credit date 66 years and 9 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 December 1960')), Date.parse('6 December 1960') + 66.years + 9.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 January 1961')), Date.parse('5 January 1961') + 66.years + 9.months
    end

    should 'return bus pass qualification date 66 years and 9 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 December 1960')), Date.parse('6 December 1960') + 66.years + 9.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 January 1961')), Date.parse('5 January 1961') + 66.years + 9.months
    end
  end

  context 'when female or male, born between 6 January 1961 and 5 February 1961' do
    should 'return state pension date 66 years and 10 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 January 1961'), gender), Date.parse('6 January 1961') + 66.years + 10.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 February 1961'), gender), Date.parse('5 February 1961') + 66.years + 10.months
      end
    end

    should 'return pension credit date 66 years and 10 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 January 1961')), Date.parse('6 January 1961') + 66.years + 10.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 February 1961')), Date.parse('5 February 1961') + 66.years + 10.months
    end

    should 'return bus pass qualification date 66 years and 10 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 January 1961')), Date.parse('6 January 1961') + 66.years + 10.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 February 1961')), Date.parse('5 February 1961') + 66.years + 10.months
    end
  end

  context 'when female or male, born between 6 February 1961 and 5 March 1961' do
    should 'return state pension date 66 years and 11 months from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 February 1961'), gender), Date.parse('6 February 1961') + 66.years + 11.months
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 March 1961'), gender), Date.parse('5 March 1961') + 66.years + 11.months
      end
    end

    should 'return pension credit date 66 years and 11 months from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 February 1961')), Date.parse('6 February 1961') + 66.years + 11.months
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 March 1961')), Date.parse('5 March 1961') + 66.years + 11.months
    end

    should 'return bus pass qualification date 66 years and 11 months from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 February 1961')), Date.parse('6 February 1961') + 66.years + 11.months
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 March 1961')), Date.parse('5 March 1961') + 66.years + 11.months
    end
  end

  context 'when female or male, born between 6 March 1961 and 5 April 1977' do
    should 'return state pension date 67 years from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 March 1961'), gender), Date.parse('6 March 1961') + 67.years
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1977'), gender), Date.parse('5 April 1977') + 67.years
      end
    end

    should 'return pension credit date 67 years from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 March 1961')), Date.parse('6 March 1961') + 67.years
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1977')), Date.parse('5 April 1977') + 67.years
    end

    should 'return bus pass qualification date 67 years from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 March 1961')), Date.parse('6 March 1961') + 67.years
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1977')), Date.parse('5 April 1977') + 67.years
    end
  end

  context 'when female or male, born between 6 April 1978 and tomorrow' do
    should 'return state pension date 68 years from date of birth' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1978'), gender), Date.parse('6 April 1978') + 68.years
        assert_equal StatePensionDateQuery.state_pension_date(Date.tomorrow, gender), Date.tomorrow + 68.years
      end
    end

    should 'return pension credit date 68 years from date of birth' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1978')), Date.parse('6 April 1978') + 68.years
      assert_equal StatePensionDateQuery.pension_credit_date(Date.tomorrow), Date.tomorrow + 68.years
    end

    should 'return bus pass qualification date 68 years from date of birth' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1978')), Date.parse('6 April 1978') + 68.years
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.tomorrow), Date.tomorrow + 68.years
    end
  end

  context 'when female, born between 6 April 1950 and 5 May 1950' do
    setup do
      @state_pension_date = Date.parse('6 May 2010')
    end

    should 'return state pension date of 6 May 2010' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 May 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 May 2010' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 May 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2010' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 May 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 May 1950 and 5 June 1950' do
    setup do
      @state_pension_date = Date.parse('6 July 2010')
    end

    should 'return state pension date of 6 July 2010' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 May 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 June 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2010' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 May 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 June 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2010' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 May 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 June 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 June 1950 and 5 July 1950' do
    setup do
      @state_pension_date = Date.parse('6 September 2010')
    end

    should 'return state pension date of 6 September 2010' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 June 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 July 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 September 2010' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 June 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 July 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2010' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 June 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 July 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 July 1950 and 5 August 1950' do
    setup do
      @state_pension_date = Date.parse('6 November 2010')
    end

    should 'return state pension date of 6 November 2010' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 July 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 August 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2010' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 July 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 August 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2010' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 July 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 August 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 August 1950 and 5 September 1950' do
    setup do
      @state_pension_date = Date.parse('6 January 2011')
    end

    should 'return state pension date of 6 January 2011' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 August 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 September 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 January 2011' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 August 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 September 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2011' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 August 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 September 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 September 1950 and 5 October 1950' do
    setup do
      @state_pension_date = Date.parse('6 March 2011')
    end

    should 'return state pension date of 6 March 2011' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 September 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 October 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2011' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 September 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 October 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2011' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 September 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 October 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 October 1950 and 5 November 1950' do
    setup do
      @state_pension_date = Date.parse('6 May 2011')
    end

    should 'return state pension date of 6 May 2011' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 October 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 November 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 May 2011' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 October 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 November 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2011' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 October 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 November 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 November 1950 and 5 December 1950' do
    setup do
      @state_pension_date = Date.parse('6 July 2011')
    end

    should 'return state pension date of 6 July 2011' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 November 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 December 1950'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2011' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 November 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1950')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2011' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 November 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 December 1950')), @state_pension_date
    end
  end

  context 'when female, born between 6 December 1950 and 5 January 1951' do
    setup do
      @state_pension_date = Date.parse('6 September 2011')
    end

    should 'return state pension date of 6 September 2011' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 December 1950'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 January 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 September 2011' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 December 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 January 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2011' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 December 1950')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 January 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 January 1951 and 5 February 1951' do
    setup do
      @state_pension_date = Date.parse('6 November 2011')
    end

    should 'return state pension date of 6 November 2011' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 January 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 February 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2011' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 January 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 February 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2011' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 January 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 February 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 February 1951 and 5 March 1951' do
    setup do
      @state_pension_date = Date.parse('6 January 2012')
    end

    should 'return state pension date of 6 January 2012' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 February 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 March 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 January 2012' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 February 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 March 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2012' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 February 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 March 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 March 1951 and 5 April 1951' do
    setup do
      @state_pension_date = Date.parse('6 March 2012')
    end

    should 'return state pension date of 6 March 2012' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 March 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2012' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 March 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2012' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 March 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 April 1951 and 5 May 1951' do
    setup do
      @state_pension_date = Date.parse('6 May 2012')
    end

    should 'return state pension date of 6 May 2012' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 May 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 May 2012' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 May 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2012' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 May 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 May 1951 and 5 June 1951' do
    setup do
      @state_pension_date = Date.parse('6 July 2012')
    end

    should 'return state pension date of 6 July 2012' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 May 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 June 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2012' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 May 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 June 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2012' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 May 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 June 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 June 1951 and 5 July 1951' do
    setup do
      @state_pension_date = Date.parse('6 September 2012')
    end

    should 'return state pension date of 6 September 2012' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 June 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 July 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 September 2012' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 June 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 July 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2012' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 June 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 July 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 July 1951 and 5 August 1951' do
    setup do
      @state_pension_date = Date.parse('6 November 2012')
    end

    should 'return state pension date of 6 November 2012' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 July 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 August 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2012' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 July 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 August 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2012' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 July 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 August 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 August 1951 and 5 September 1951' do
    setup do
      @state_pension_date = Date.parse('6 January 2013')
    end

    should 'return state pension date of 6 January 2013' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 August 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 September 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 January 2013' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 August 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 September 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2013' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 August 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 September 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 September 1951 and 5 October 1951' do
    setup do
      @state_pension_date = Date.parse('6 March 2013')
    end

    should 'return state pension date of 6 March 2013' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 September 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 October 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2013' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 September 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 October 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2013' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 September 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 October 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 October 1951 and 5 November 1951' do
    setup do
      @state_pension_date = Date.parse('6 May 2013')
    end

    should 'return state pension date of 6 May 2013' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 October 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 November 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 May 2013' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 October 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 November 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2013' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 October 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 November 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 November 1951 and 5 December 1951' do
    setup do
      @state_pension_date = Date.parse('6 July 2013')
    end

    should 'return state pension date of 6 July 2013' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 November 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 December 1951'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2013' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 November 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1951')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2013' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 November 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 December 1951')), @state_pension_date
    end
  end

  context 'when female, born between 6 December 1951 and 5 January 1952' do
    setup do
      @state_pension_date = Date.parse('6 September 2013')
    end

    should 'return state pension date of 6 September 2013' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 December 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 January 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 September 2013' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 December 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 January 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2013' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 December 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 January 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 December 1951 and 5 January 1952' do
    setup do
      @state_pension_date = Date.parse('6 September 2013')
    end

    should 'return state pension date of 6 September 2013' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 December 1951'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 January 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 September 2013' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 December 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 January 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2013' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 December 1951')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 January 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 January 1952 and 5 February 1952' do
    setup do
      @state_pension_date = Date.parse('6 November 2013')
    end

    should 'return state pension date of 6 November 2013' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 January 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 February 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2013' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 January 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 February 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2013' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 January 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 February 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 February 1952 and 5 March 1952' do
    setup do
      @state_pension_date = Date.parse('6 January 2014')
    end

    should 'return state pension date of 6 January 2014' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 February 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 March 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 January 2014' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 February 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 March 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2014' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 February 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 March 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 March 1952 and 5 April 1952' do
    setup do
      @state_pension_date = Date.parse('6 March 2014')
    end

    should 'return state pension date of 6 March 2014' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 March 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2014' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 March 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2014' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 March 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 April 1952 and 5 May 1952' do
    setup do
      @state_pension_date = Date.parse('6 May 2014')
    end

    should 'return state pension date of 6 May 2014' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 May 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 May 2014' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 May 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2014' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 May 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 May 1952 and 5 June 1952' do
    setup do
      @state_pension_date = Date.parse('6 July 2014')
    end

    should 'return state pension date of 6 July 2014' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 May 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 June 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2014' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 May 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 June 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2014' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 May 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 June 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 June 1952 and 5 July 1952' do
    setup do
      @state_pension_date = Date.parse('6 September 2014')
    end

    should 'return state pension date of 6 September 2014' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 June 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 July 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 September 2014' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 June 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 July 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2014' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 June 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 July 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 July 1952 and 5 August 1952' do
    setup do
      @state_pension_date = Date.parse('6 November 2014')
    end

    should 'return state pension date of 6 November 2014' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 July 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 August 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2014' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 July 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 August 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2014' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 July 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 August 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 August 1952 and 5 September 1952' do
    setup do
      @state_pension_date = Date.parse('6 January 2015')
    end

    should 'return state pension date of 6 January 2015' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 August 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 September 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 January 2015' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 August 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 September 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2015' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 August 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 September 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 September 1952 and 5 October 1952' do
    setup do
      @state_pension_date = Date.parse('6 March 2015')
    end

    should 'return state pension date of 6 March 2015' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 September 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 October 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2015' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 September 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 October 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2015' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 September 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 October 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 October 1952 and 5 November 1952' do
    setup do
      @state_pension_date = Date.parse('6 May 2015')
    end

    should 'return state pension date of 6 May 2015' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 October 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 November 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 May 2015' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 October 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 November 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2015' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 October 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 November 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 November 1952 and 5 December 1952' do
    setup do
      @state_pension_date = Date.parse('6 July 2015')
    end

    should 'return state pension date of 6 July 2015' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 November 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 December 1952'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2015' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 November 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1952')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2015' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 November 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 December 1952')), @state_pension_date
    end
  end

  context 'when female, born between 6 December 1952 and 5 January 1953' do
    setup do
      @state_pension_date = Date.parse('6 September 2015')
    end

    should 'return state pension date of 6 September 2015' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 December 1952'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 January 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 September 2015' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 December 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 January 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2015' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 December 1952')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 January 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 January 1953 and 5 February 1953' do
    setup do
      @state_pension_date = Date.parse('6 November 2015')
    end

    should 'return state pension date of 6 November 2015' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 January 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 February 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2015' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 January 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 February 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2015' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 January 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 February 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 February 1953 and 5 March 1953' do
    setup do
      @state_pension_date = Date.parse('6 January 2016')
    end

    should 'return state pension date of 6 January 2016' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 February 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 March 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 January 2016' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 February 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 March 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2016' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 February 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 March 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 March 1953 and 5 April 1953' do
    setup do
      @state_pension_date = Date.parse('6 March 2016')
    end

    should 'return state pension date of 6 March 2016' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 March 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2016' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 March 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2016' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 March 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 April 1953 and 5 May 1953' do
    setup do
      @state_pension_date = Date.parse('6 July 2016')
    end

    should 'return state pension date of 6 July 2016' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 May 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2016' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 May 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2016' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 May 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 May 1953 and 5 June 1953' do
    setup do
      @state_pension_date = Date.parse('6 November 2016')
    end

    should 'return state pension date of 6 November 2016' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 May 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 June 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2016' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 May 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 June 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2016' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 May 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 June 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 June 1953 and 5 July 1953' do
    setup do
      @state_pension_date = Date.parse('6 March 2017')
    end

    should 'return state pension date of 6 March 2017' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 June 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 July 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2017' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 June 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 July 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2017' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 June 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 July 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 July 1953 and 5 August 1953' do
    setup do
      @state_pension_date = Date.parse('6 July 2017')
    end

    should 'return state pension date of 6 July 2017' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 July 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 August 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2017' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 July 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 August 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2017' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 July 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 August 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 August 1953 and 5 September 1953' do
    setup do
      @state_pension_date = Date.parse('6 November 2017')
    end

    should 'return state pension date of 6 November 2017' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 August 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 September 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 November 2017' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 August 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 September 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2017' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 August 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 September 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 September 1953 and 5 October 1953' do
    setup do
      @state_pension_date = Date.parse('6 March 2018')
    end

    should 'return state pension date of 6 March 2018' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 September 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 October 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 March 2018' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 September 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 October 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2018' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 September 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 October 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 October 1953 and 5 November 1953' do
    setup do
      @state_pension_date = Date.parse('6 July 2018')
    end

    should 'return state pension date of 6 July 2018' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 October 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 November 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2018' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 October 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 November 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2018' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 October 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 November 1953')), @state_pension_date
    end
  end

  context 'when female, born between 6 November 1953 and 5 December 1953' do
    setup do
      @state_pension_date = Date.parse('6 November 2018')
    end

    should 'return state pension date of 6 July 2018' do
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 November 1953'), :female), @state_pension_date
      assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 December 1953'), :female), @state_pension_date
    end

    should 'return pension credit date of 6 July 2018' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 November 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1953')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2018' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 November 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 December 1953')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 December 1953 and 5 January 1954' do
    setup do
      @state_pension_date = Date.parse('6 March 2019')
    end

    should 'return state pension date of 6 March 2019' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 December 1953'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 January 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 March 2019' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 December 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 January 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2019' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 December 1953')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 January 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 January 1954 and 5 February 1954' do
    setup do
      @state_pension_date = Date.parse('6 May 2019')
    end

    should 'return state pension date of 6 May 2019' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 January 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 February 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 May 2019' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 January 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 February 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2019' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 January 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 February 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 February 1954 and 5 March 1954' do
    setup do
      @state_pension_date = Date.parse('6 July 2019')
    end

    should 'return state pension date of 6 July 2019' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 February 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 March 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 July 2019' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 February 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 March 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2019' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 February 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 March 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 March 1954 and 5 April 1954' do
    setup do
      @state_pension_date = Date.parse('6 September 2019')
    end

    should 'return state pension date of 6 September 2019' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 March 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 September 2019' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 March 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2019' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 March 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 April 1954 and 5 May 1954' do
    setup do
      @state_pension_date = Date.parse('6 November 2019')
    end

    should 'return state pension date of 6 November 2019' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 May 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 November 2019' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 May 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2019' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 May 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 May 1954 and 5 June 1954' do
    setup do
      @state_pension_date = Date.parse('6 January 2020')
    end

    should 'return state pension date of 6 January 2020' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 May 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 June 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 January 2020' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 May 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 June 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2020' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 May 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 June 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 June 1954 and 5 July 1954' do
    setup do
      @state_pension_date = Date.parse('6 March 2020')
    end

    should 'return state pension date of 6 March 2020' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 June 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 July 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 March 2020' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 June 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 July 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2020' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 June 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 July 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 July 1954 and 5 August 1954' do
    setup do
      @state_pension_date = Date.parse('6 May 2020')
    end

    should 'return state pension date of 6 May 2020' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 July 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 August 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 May 2020' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 July 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 August 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2020' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 July 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 August 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 August 1954 and 5 September 1954' do
    setup do
      @state_pension_date = Date.parse('6 July 2020')
    end

    should 'return state pension date of 6 July 2020' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 August 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 September 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 July 2020' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 August 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 September 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2020' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 August 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 September 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 September 1954 and 5 October 1954' do
    setup do
      @state_pension_date = Date.parse('6 September 2020')
    end

    should 'return state pension date of 6 September 2020' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 September 1954'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 October 1954'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 September 2020' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 September 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 October 1954')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2020' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 September 1954')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 October 1954')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 April 1977 and 5 May 1977' do
    setup do
      @state_pension_date = Date.parse('6 May 2044')
    end

    should 'return state pension date of 6 May 2044' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 April 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 May 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 May 2044' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 April 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 May 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2044' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 April 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 May 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 May 1977 and 5 June 1977' do
    setup do
      @state_pension_date = Date.parse('6 July 2044')
    end

    should 'return state pension date of 6 July 2044' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 May 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 June 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 July 2044' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 May 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 June 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2044' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 May 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 June 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 June 1977 and 5 July 1977' do
    setup do
      @state_pension_date = Date.parse('6 September 2044')
    end

    should 'return state pension date of 6 September 2044' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 June 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 July 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 September 2044' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 June 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 July 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2044' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 June 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 July 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 July 1977 and 5 August 1977' do
    setup do
      @state_pension_date = Date.parse('6 November 2044')
    end

    should 'return state pension date of 6 November 2044' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 July 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 August 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 November 2044' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 July 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 August 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2044' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 July 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 August 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 August 1977 and 5 September 1977' do
    setup do
      @state_pension_date = Date.parse('6 January 2045')
    end

    should 'return state pension date of 6 January 2045' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 August 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 September 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 January 2045' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 August 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 September 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2045' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 August 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 September 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 September 1977 and 5 October 1977' do
    setup do
      @state_pension_date = Date.parse('6 March 2045')
    end

    should 'return state pension date of 6 March 2045' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 September 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 October 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 March 2045' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 September 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 October 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2045' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 September 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 October 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 October 1977 and 5 November 1977' do
    setup do
      @state_pension_date = Date.parse('6 May 2045')
    end

    should 'return state pension date of 6 May 2045' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 October 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 November 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 May 2045' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 October 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 November 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 May 2045' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 October 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 November 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 November 1977 and 5 December 1977' do
    setup do
      @state_pension_date = Date.parse('6 July 2045')
    end

    should 'return state pension date of 6 July 2045' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 November 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 December 1977'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 July 2045' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 November 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 December 1977')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 July 2045' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 November 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 December 1977')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 December 1977 and 5 January 1978' do
    setup do
      @state_pension_date = Date.parse('6 September 2045')
    end

    should 'return state pension date of 6 September 2045' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 December 1977'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 January 1978'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 September 2045' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 December 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 January 1978')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 September 2045' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 December 1977')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 January 1978')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 January 1978 and 5 February 1978' do
    setup do
      @state_pension_date = Date.parse('6 November 2045')
    end

    should 'return state pension date of 6 November 2045' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 January 1978'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 February 1978'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 November 2045' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 January 1978')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 February 1978')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 November 2045' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 January 1978')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 February 1978')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 February 1978 and 5 March 1978' do
    setup do
      @state_pension_date = Date.parse('6 January 2046')
    end

    should 'return state pension date of 6 January 2046' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 February 1978'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 March 1978'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 January 2046' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 February 1978')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 March 1978')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 January 2046' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 February 1978')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 March 1978')), @state_pension_date
    end
  end

  context 'when female or male, born between 6 March 1978 and 5 April 1978' do
    setup do
      @state_pension_date = Date.parse('6 March 2046')
    end

    should 'return state pension date of 6 March 2046' do
      [:female, :male].each do |gender|
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('6 March 1978'), gender), @state_pension_date
        assert_equal StatePensionDateQuery.state_pension_date(Date.parse('5 April 1978'), gender), @state_pension_date
      end
    end

    should 'return pension credit date of 6 March 2046' do
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('6 March 1978')), @state_pension_date
      assert_equal StatePensionDateQuery.pension_credit_date(Date.parse('5 April 1978')), @state_pension_date
    end

    should 'return a bus pass qualification date of 6 March 2046' do
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('6 March 1978')), @state_pension_date
      assert_equal StatePensionDateQuery.bus_pass_qualification_date(Date.parse('5 April 1978')), @state_pension_date
    end
  end
end
