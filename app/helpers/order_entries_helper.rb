module OrderEntriesHelper
  def entry_options(category)
    return ServiceType.find_by_name(category).services.collect{|x| x.name}
  end
end
