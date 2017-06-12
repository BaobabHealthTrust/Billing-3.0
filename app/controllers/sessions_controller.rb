class SessionsController < ApplicationController

  def login
    render :layout => 'touch'
  end

  def create_session

    state = User.authenticate(params['login'],params['password'])

    if state
      user = User.find_by_username(params['login'])
      session[:user_id] = user.id
      @current_user = user
      flash[:errors] = nil
      redirect_to "/location" and return
    else
      flash[:errors] = "Invalid user credentials"
      redirect_to '/login' and return
    end

  end

  def destroy
    session[:user_id] = nil
    @current_user = nil
    redirect_to '/login' and return
  end
end
