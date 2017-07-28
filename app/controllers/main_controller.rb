class MainController < ApplicationController
  def index
    range = DateTime.current.beginning_of_day..DateTime.current.end_of_day
    @collected = OrderPayment.select("COALESCE(sum(amount),0) as amount").where(payment_stamp: range).first.amount rescue 0
    @billed = OrderEntry.select("COALESCE(sum(full_price),0) as amount").where(order_date: range).first.amount rescue 0
    @registrations = Patient.select("COALESCE(count(*),0) as number").where(date_created: range).first.number rescue 0
    @cash_payments = OrderPayment.select("COALESCE(count(*),0) as number").where(payment_stamp: range, payment_mode: "CASH").first.number rescue 0
    @pending = @billed - @collected

  end

  def report_select

    case params[:report_type]
      when 'income_summary'
        @report_path = "/main/income_summary"
      when 'cashier_summary'
        @report_path = "/main/cashier_summary"
        @cashier_options = User.all.collect{ |x| [x.id, x.name]}
      when 'daily_cash_summary'
        @report_path = "/main/daily_cash_summary"
    end
    render :layout => 'touch'
  end

  def income_summary
    case params[:report_duration]
      when 'Daily'
        @title = "Daily Income Summary for #{params[:start_date].to_date.strftime('%d %B, %Y')}"
        range = params[:start_date].to_date.beginning_of_day..params[:start_date].to_date.end_of_day
      when 'Weekly'
        @title = "Weekly Income Summary from #{params[:start_date].to_date.beginning_of_week.strftime('%d %B, %Y')} to
#{params[:start_date].to_date.end_of_week.strftime('%d %B, %Y')}"
        range = params[:start_date].to_date.beginning_of_week.beginning_of_day..params[:start_date].to_date.end_of_week.end_of_day
      when 'Monthly'
        @title = "Monthly Income Summary for #{params[:start_date].to_date.strftime('%B %Y')}"
        range = params[:start_date].to_date.beginning_of_month.beginning_of_day..params[:start_date].to_date.end_of_month.end_of_day
      when 'Range'
        @title = "Income Summary from #{params[:start_date].to_date.strftime('%d %B, %Y')} to #{params[:end_date].to_date.strftime('%d %B, %Y')}"
        range = params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day
    end

    data = Receipt.find_by_sql("Select * from receipts where payment_stamp between '#{range.first.strftime('%Y-%m-%d 00:00:00')}'
                                         and '#{range.last.strftime('%Y-%m-%d 23:59:59')}'")

    @records = view_context.income_summary(data)

  end

  def cashier_summary
    @user = User.find(params[:cashier]) rescue nil
    case params[:report_duration]
      when 'Daily'
        @title = "Daily income summary for #{params[:start_date].to_date.strftime('%d %B, %Y')} transactions  by #{@user.name}"
        range = params[:start_date].to_date.beginning_of_day..params[:start_date].to_date.end_of_day
      when 'Weekly'
        @title = "Weekly Income Summary from #{params[:start_date].to_date.beginning_of_week.strftime('%d %B, %Y')} to
                  #{params[:start_date].to_date.end_of_week.strftime('%d %B, %Y')}  transactions  by #{@user.name}"
        range = params[:start_date].to_date.beginning_of_week.beginning_of_day..params[:start_date].to_date.end_of_week.end_of_day
      when 'Monthly'
        @title = "Monthly Income Summary for #{params[:start_date].to_date.strftime('%B %Y')}  transactions  by #{@user.name}"
        range = params[:start_date].to_date.beginning_of_month.beginning_of_day..params[:start_date].to_date.end_of_month.end_of_day
      when 'Range'
        @title = "Income Summary from #{params[:start_date].to_date.strftime('%d %B, %Y')} to
                 #{params[:end_date].to_date.strftime('%d %B, %Y')}  transactions  by #{@user.name}"
        range = params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day
    end

    data = Receipt.find_by_sql("Select * from receipts where payment_stamp between '#{range.first.strftime('%Y-%m-%d 00:00:00')}'
                                         and '#{range.last.strftime('%Y-%m-%d 23:59:59')}' and cashier = #{params[:cashier]}")

    @records = view_context.income_summary(data)
  end

  def daily_cash_summary
    @headers = [%w[Consultation 0011 0071], %w[Book 0012 0072],%w[Drugs 0011 0071], %w[Laboratory 0012 0072],
                %w[Radiology 0011 0071], %w[Book 0012 0072],%w[Consultation 0011 0071], %w[Book 0012 0072],
                %w[Consultation 0011 0071], %w[Book 0012 0072],%w[Consultation 0011 0071], %w[Book 0012 0072]]

    range = params[:start_date].to_date.beginning_of_day..params[:start_date].to_date.end_of_day rescue ''
    data = OrderPayment.find_by_sql("Select * from order_payments where created_at between '#{range.first.strftime('%Y-%m-%d 00:00:00')}'
                                         and '#{range.last.strftime('%Y-%m-%d 23:59:59')}' ") rescue []

    @start_date = range.first.to_date
    @end_date = range.last.to_date
    @records,@totals = view_context.cash_summary(data)
  end

  def print_daily_cash_summary

    data = OrderPayment.find_by_sql("Select * from order_payments where created_at between '#{params[:start_date].to_date.strftime('%Y-%m-%d 00:00:00')}'
                                         and '#{params[:end_date].to_date.strftime('%Y-%m-%d 23:59:59')}' ") rescue []

    date = params[:start_date].to_date.strftime('%d %B, %Y')
    data,totals = view_context.cash_summary(data)
    print_string = Misc.print_summary(data,totals,date, current_user.name)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbs", :disposition => "inline")
  end
end
