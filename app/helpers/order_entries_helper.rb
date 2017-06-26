module OrderEntriesHelper
  def entry_options(category)
    return ServiceType.find_by_name(category).services.collect{|x| x.name}
  end
  def panel_options(category)
    return ServiceType.find_by_name(category).service_panels.collect{|x| x.name} + ["Other"]
  end
  def sig
    return ["BID", "EOD", "OD","TDS","q.h","q.2.h","q.3.h","q.4.h", "q.d.s"]
  end
end
