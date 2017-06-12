class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate, :except => ['login', 'create_session']
  helper_method :current_user

  def print_and_redirect(print_url, redirect_url, message = "Printing label ...", show_next_button = false, patient_id = nil)
    #Function handles redirects when printing labels
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    render :layout => false
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end


  def authenticate
    if current_user.blank?
      redirect_to "/login" and return
    else
      return true
    end
  end

  private
  def name_of_app
    return "Billing"
  end

  def facility_code
    return YAML.load_file("#{Rails.root}/config/application.yml")['facility_code']
  end

end
