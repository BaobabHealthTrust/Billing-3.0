class UserPropertiesController < ApplicationController

  def edit
    @edit_property = params[:property]
    render :layout => 'touch'
  end

  def update
    property = UserProperty.where(property: params[:property],user_id: params[:id]).first_or_initialize
    property.property_value = params[params[:property]]
    property.save
    redirect_to root_path and return
  end
end
