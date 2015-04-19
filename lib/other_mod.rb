
module OtherMod   

  SiteTabs = %w[this site sys]
  SiteTabs.each { |m| define_method("#{m}_tab") {session["#{m}_tab".to_sym] = request.request_uri.delete("/")} }
 
  def site_menu
    @tabmenus=FreedReport::Tabmenu.find(:all,:conditions=>"(modelname='SQL报表' or modelname='手动报表' ) and parent_id = id and top_style<>1",:order=>"id")
    #@tabmenus=Ultra::Tabmenu.find(:all,:conditions=>"modelname='#{controller.menu_item}' and parent_id is null",:order=>"id")
  end

  def to_chart_hash(str)
     #属性转hash格式加载--2014-4-28--lij李江锋
     str.split(",").map{|a| a.split("=>")}.inject({}){|h,a| h[a[0].gsub(":",'')] = a[1].gsub('\'','');h}
  end

  def check_whether_link(g,d,item_link,notice)
    #前置报表是否钻取判断；params+本行data参数打包
    if item_link
      if item_link&&item_link[0..11]==":report_id=>"
       g.d link_to notice,{:controller=>"freed_report/ult_freed_reports",:action=>"index",:report_id=>item_link[12..-1].to_i}.merge({:my_params=>@params_url}){ |key, v1, v2| v1 }.merge({:my_values=>d}),:target=>"_blank"
      else
       g.d link_to notice,to_chart_hash(item_link).merge({:my_params=>@params_url}).merge({:my_values=>d}),:target=>"_blank"
      end
    else
       g.d notice
    end
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
