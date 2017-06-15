module ApplicationHelper
  def title(page_title, options={})
    content_for(:title, page_title.to_s)
    return content_tag(:h1, page_title, options)
  end

  def name_of_app
    return "Billing"
  end

  def facility_code
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_code']
  end

  def facility_name
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']
  end

  def show_intro_text
    return false # get_global_property_value("show_intro_text").to_s == "true" rescue false
  end

  def month_name_options(selected_months = [])
    i=0
    options_array = [[]] +Date::ABBR_MONTHNAMES[1..-1].collect{|month|[month,i+=1]} + [["Unknown","Unknown"]]
    options_for_select(options_array, selected_months)
  end

  def version
    style = "style='background-color:red;'" unless session[:datetime].blank?
    "National EMR:Patient Registration: #{PR_VERSION} - <span #{style}>#{(session[:datetime].to_date rescue Date.today).strftime('%A, %d-%b-%Y')}</span>&nbsp;&nbsp;"
  end

  def welcome_message
    'Muli bwanji, enter your user information or scan your id card.'
  end

  def preferred_user_keyboard
    UserProperty.find(:first,
                      :conditions =>["property = ? AND user_id = ?",'preferred.keyboard',
                                     current_user.id]).property_value rescue 'qwerty'
  end
end
