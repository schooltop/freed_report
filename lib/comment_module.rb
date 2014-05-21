
module Comment_Module

def method_missing(method_name, *args)
  @method_name=method_name
  @report_source=FreedReport::UltraCompanyChart.find(:first,:conditions=>"action_title='#{@method_name}'")
  if  @report_source
      excute_page_sql(@report_source)
  else
      super
  end
end

def first_page_views
     page_db_connects
      if params[:time_gran]=="month"
       @privince_month=FreedReport::UltraCompanyChart.find(:all,:conditions=>"area_gran='province' and time_gran='month' and top_style=1" ,:order=>"parent_id")
       @privince_month.each{|pm| excute_page_sql(pm)}
      else
       @privince_day=FreedReport::UltraCompanyChart.find(:all,:conditions=>"area_gran='province' and time_gran='day' and top_style=1" ,:order=>"parent_id")
       @privince_day.each{|pd| excute_page_sql(pd)}
      end
     @dbh.disconnect if @dbh
end

def excute_page_sql(exc_object)
   
    if exc_object.da_source==1
      #数据源取自报表
      @chart_ult_freed_reports=instance_variable_get("@ult_freed_report")
    elsif exc_object.da_source==2
      #数据源取自父图表
      @chart_ult_freed_reports=instance_variable_get("@#{exc_object.parent_chart}")
    else
      @chart_ult_freed_reports=[]
      @cullent_attributes=@dbh.execute(content_params(exc_object.chart_sql))
      #获取报表展示字段
      @columns=@cullent_attributes.column_names  
      @cullent_attributes.each do |report|
              b={}
              report.each_with_index do |a , x|
                 b[@columns[x]]=a.to_s
              end
              #组装结果集
              @chart_ult_freed_reports<<b
      end
    end
    #图表对象
    instance_variable_set("@#{exc_object.action_title}_column", exc_object)
    #图表数据源
    instance_variable_set("@#{exc_object.action_title}",@chart_ult_freed_reports)
end

def content_params(content_sql)
    message = content_sql
    #替换搜索条件
    message.gsub!("￥begin_time", params[:begin_time]) 
    return message
end


 def page_db_connects #数据库参数获取
    username = $CFG['username']
    password = $CFG['password']
    database = $CFG['database']
    database = "DBI:OCI8:#{database}"
    @dbh = DBI.connect(database,username,password)
 end
   
end
