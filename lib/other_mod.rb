
module OtherMod   

  SiteTabs = %w[this site sys]
  SiteTabs.each { |m| define_method("#{m}_tab") {session["#{m}_tab".to_sym] = request.request_uri.delete("/")} }
 
  def site_menu
    @tabmenus=FreedReport::Tabmenu.find(:all,:conditions=>"modelname='#{session[:sys_tab]}' and parent_id = id and top_style<>1",:order=>"id")
  end

   
  def derive_alarm(name,pare='Ap',leave="") #告警伐值比对逻辑-2013-7-李江锋ljf,衍生告警name参数名、pare设备粒度、leave时间粒度
     alarm=Ultra::WlanIndexDef.find_by_name_en(name)
     @molecule=alarm.molecule
     @denominator=alarm.denominator
     alarm_table_name(pare,leave)
  end

  def alarm_table_name(area_gran,time_gran="")   #获取model名称
     @model_table="wlan_"+area_gran+"_perf_aggr"+(time_gran&&time_gran!="" ? ("_"+time_gran) : "" )
  end

  def kgf(num)   #添加空格符号
    a="&nbsp;"
    num.to_i.times do
    a=a+"&nbsp;"
    end
    return a
  end

end
