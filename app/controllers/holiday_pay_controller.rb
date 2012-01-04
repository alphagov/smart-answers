class HolidayPayController < ApplicationController
  before_filter :calculate, :if => :params_present?

  STATUTORY_WEEKS = 5.6

  def index 
    @defaults = { 
      :period         => :full_year,
      :date           => Time.now,
      :start_date     => Time.parse('1 January 2011'),
      :pay_period     => :days,
      :days_per_week  => 5,
      :hours_per_week => 35
    }
    @options = @options.nil? ? @defaults : @defaults.merge(@options)
                                                     
    set_slimmer_headers :section => 'work'

    respond_to do |format|
      format.html { render }
      format.json { 
        if @result.present?
          render :json => { "entitlement" => @result[:final_amount], "entitlement_period" => @result[:pay_period], "workings" => @result[:workings] }
        else
          render :json => { }
        end
      }
    end
  end

  private
  def calculate
    @options = {}

    case params[:period]
    when "full_year"
      @options[:period] = :full_year
    else
      @options[:period] = params["leave_join"] == "leaving" ? :leaving : :joining      
    end                                           

    case params[:pay_period]
    when "daily"
      @options[:pay_period] = :days
    when "hourly"
      @options[:pay_period] = :hours              
    else
      return false
    end

    @options[:date] = parse_date(params[:leave_join_date])
    @options[:start_date] = parse_date(params[:start_date])
    @options[:days_per_week] = params[:days_per_week].to_i
    @options[:hours_per_week] = params[:hours_per_week].to_i

    return false if @options[:hours_per_week] < 1 and @options[:pay_period] == :hours
    return false if @options[:days_per_week] > 5 and @options[:pay_period] == :days

    @result = evaluate_formula @options
  end

  def evaluate_formula(options)
    case options[:pay_period]
    when :days
      workings = "#{STATUTORY_WEEKS} (statutory requirement) x #{options[:days_per_week]} days"
      annual_entitlement = STATUTORY_WEEKS * options[:days_per_week]
    when :hours
      workings = "#{STATUTORY_WEEKS} (statutory requirement) x #{options[:hours_per_week]} hours"
      annual_entitlement = STATUTORY_WEEKS * options[:hours_per_week]
    end

    unless options[:period] == :full_year
      count_days = days_difference(options[:start_date],options[:date])
      days_in_year = Date.leap?(options[:date].year) ? 366.0 : 365.0  
      proportion = count_days/days_in_year                               
    end

    case options[:period]
    when :full_year
      proportion = 1
    when :joining
      if options[:date] > options[:start_date]
        proportion = 1 - proportion
      end
      workings += " x #{proportion.round(2)} (proportion of holiday year left)"
    when :leaving
      if options[:date] <= options[:start_date]
        proportion = 1 - proportion
      end
      workings += " x #{proportion.round(2)} (proportion of holiday year worked)"
    end                            
    proportion = proportion.round(2)

    final_amount = annual_entitlement * proportion
    final_amount = round_up(final_amount, 1)

    workings += " = #{final_amount} #{options[:pay_period]}"

    { 
      :final_amount => final_amount,
      :pay_period   => options[:pay_period],
      :workings     => workings,
    }
  end

  def parse_date(date)
    day,month,year = "(3i)", "(2i)", "(1i)"  
    Time.utc(date[year],date[month],date[day])
  end

  def days_difference(date1,date2)
    d1y,d2y = date1.yday,date2.yday
    (d1y >= d2y) ? d1y - d2y : d2y - d1y
  end                           

  def round_up(float, decimal_places)
    (float * 10**decimal_places).ceil.to_f / 10**decimal_places
  end

  def params_present?
    #params[:commit].present?
    [:period,:pay_period,:start_date].each {|key| return false unless params[key].present? }
  end
end