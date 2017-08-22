class DepositsController < ApplicationController
  def new
    render layout: 'touch'
  end

  def create

    new_deposit = Deposit.new()
    new_deposit.amount_received= params[:deposit][:amount_received]
    new_deposit.amount_available= params[:deposit][:amount_received]
    new_deposit.creator = User.find_by_user_id(params[:deposit][:creator])
    new_deposit.patient_id= params[:deposit][:patient_id]
    new_deposit.save

    if new_deposit.errors.blank?
      print_and_redirect("/patients/#{params[:patient_id]}/deposits/#{new_deposit.id}",
                         "/patients/#{params[:patient_id]}")

    else
      redirect_to "/patients/#{params[:patient_id]}"
    end

  end

  def index
    @patient = Patient.find(params[:patient_id])
    @deposits = Deposit.where(patient_id: params[:patient_id]).order("amount_available DESC, created_at DESC")
  end

  def show

    print_string = Misc.print_deposit_receipt(params[:id])

    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
              :filename=>"#{(0..8).map { (65 + rand(26)).chr }.join}.lbs", :disposition => "inline")
  end

  private

  def deposit_params
    params.require(:deposit).permit(:amount_received,:patient_id, :creator)
  end
end
