class UsersController < ApplicationController
  def index
    @users = User.all
  end
  def new
    render :layout => 'touch'
  end
  def create

  end
  def edit
    @field = (params[:attribute] == 'name' ? 'NAME' : 'PASSWORD')
    render :layout => 'touch'
  end
  def update

    @user = User.find(params[:user_id])
    redirect_to "/" and return if @user.blank?

    case params[:fields]
      when 'NAME'
        person_name = PersonName.create(given_name: params[:given_name], family_name: params[:family_name] , person_id: @user.person_id)

        if person_name.blank? || !person_name.errors.blank?
          flash[:error] = 'User details could not be updated'
        else
          flash[:notice] = 'User details successfully updated'
        end

      when 'PASSWORD'

        if params[:password] == params[:confirm_password]
          @user.plain_password = params[:password]
          @user.save
        else
          flash[:error] = 'User passwords did not match'
        end
    end

    redirect_to @user
  end
  def show

  end
  def destroy

  end
end
