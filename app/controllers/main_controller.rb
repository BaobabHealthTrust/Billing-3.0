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
    data = OrderPayment.find_by_sql("Select * from order_payments where payment_stamp between '#{range.first}'
                                         and '#{range.last}'")
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

    data = OrderPayment.find_by_sql("Select * from order_payments where payment_stamp between '#{range.first}'
                                         and '#{range.last}' and cashier = #{params[:cashier]}")
    @records = view_context.income_summary(data)
  end

  def daily_cash_summary

  end
end
