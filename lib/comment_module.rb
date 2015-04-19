
module Comment_Module
#图表异步加载页面处理逻辑----2014-7-15---李江锋ljf
def method_missing(method_name, *args)
  @method_name=method_name
  @report_source=FreedReport::UltraCompanyChart.find(:first,:conditions=>"action_title='#{@method_name}'")
  if  @report_source
      page_db_connects
      excute_page_sql(@report_source)
      @dbh.disconnect if @dbh
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
      @current_model=exc_object
      @chart_ult_freed_reports=[]
      #if exc_object.da_source==1
      #数据源取自报表
      #@chart_ult_freed_reports=instance_variable_get("@ult_freed_report")
      #else
      @cullent_attributes=@dbh.execute(content_params(exc_object))
      #获取报表展示字段
      @columns=@cullent_attributes.column_names  
      @cullent_attributes.each do |report|
              b={}
              report.each_with_index do |a , x|
                 b[@columns[x]]=a.to_s
              end
              #组装结果集
              @chart_ult_freed_reports<<b
      #end
    end
    #图表对象
    instance_variable_set("@#{exc_object.action_title}_column", exc_object)
    #图表数据源
    instance_variable_set("@#{exc_object.action_title}",@chart_ult_freed_reports)

end

def content_params(content_sql)
    message = content_sql.chart_sql
    #图表切换异步传参获取
    if params[:chart_params]&&params[:chart_params]!=""
      @my_params_first=params[:chart_params].split("￥")
      @my_params_first.each { |f| message.gsub!("￥#{f.split("|")[0]}", "#{f.split("|")[1]}") if message.include?"￥#{f.split("|")[0]}"}
    end
#    sub_search
#    @my_params.each_with_index do |m,x|
#    has_compare_option?(content,style,name,singer,check,option,m=nil,x=nil)
#    end
    return message
end

def sub_search
      #截取查询条件--李江锋ljf--2013-11-12  0为name，1为中文标注，2为符号，3为标签，4为取值  例子：name/名称/=/select/[["李","1"],["江","2"],["锋","3"]]&name/名称/=/select/[["李","1"],["江","2"],["锋","3"]]
      @my_params=[]
      if @current_model&&@current_model.form_title&&@current_model.form_title!=""
      @my_params_first=@current_model.form_title.split("￥")
      @my_params_first.each { |f| @my_params<<f.split("#")}
      end
  end


def has_compare_option?(content,style,name,singer,check,option,m=nil,x=nil)
    #style有大于、小于、等于、like----李江锋ljf--2013-11-12
    check_option=(option!='pk'? (singer=="like"? "'%#{option}%'" : " '#{option}'"): "''")
    unless (check.nil? || check.empty?)
      if style=="time"
        #--时间截取处理---------------------
        if @current_model.time_gran=="hour"
           option=Time.now.yesterday.strftime('%Y-%m-%d %H:%M:%S') if option.nil? || option.empty? || option==['']
           where_con = (option.nil? || option.empty? || option==['']) ? "" : check.sub(/\d*[-\/]\d*[-\/]\d* \d\d:\d\d:\d\d/,option)
        else
           option=Time.now.yesterday.strftime('%Y-%m-%d') if option.nil? || option.empty? || option==['']
           if check.match(/\d*[-\/]\d*[-\/]\d*/)
             where_con = (option.nil? || option.empty? || option==['']) ? "" : check.sub(/\d*[-\/]\d*[-\/]\d*/,option)
           elsif check.match(/\d*[-\/]\d*/)
             where_con = (option.nil? || option.empty? || option==['']) ? "" : check.sub(/\d*[-\/]\d*/,option.to_date.strftime('%Y-%m'))
           else
             where_con = (option.nil? || option.empty? || option==['']) ? "" : check.gsub(/\d*\d/,option)
           end
        end
      elsif style=="checkbox"
           where_con = (option.nil? || option.empty? || option==['']) ? "" : " and #{name} #{singer} "+ check_option
      else
           where_con = (option.nil? || option.empty? || option==['']) ? "" : " and #{name} #{singer} "+ check_option
      end
      #替换搜索条件
      content.gsub!(check, where_con)
      #替换搜索配置参数
      if m
         content.gsub!("￥#{m[1]}",params["#{m[0]}#{x}"]) if content.include?"￥#{m[1]}"
      end
      end
  end

 def page_db_connects #数据库参数获取
    username = $CFG['username']
    password = $CFG['password']
    database = $CFG['database']
    database = "DBI:OCI8:#{database}"
    @dbh = DBI.connect(database,username,password)
 end
   
end
  