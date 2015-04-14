# 实现数据库连接、模版调用解析。
#支持自定义数据源(支持oracle、mysql等/可由dbi扩充支持)、自定义sql脚本、自定义条件查询、自动生成导航连接。

module DbSql
  require 'dbi'#获得dbi的数据库连接支持gem库包

  def excute_other_sql  #报表统一解析查询接口 2013-12-31版--李江锋ljf
     reportid=params[:report_id].to_i
     @ult_freed_reports=[]
     @page_ult_freed_reports=[]
     model_search(reportid)

      @ultra_company_db_model=@current_model.ultra_company_db_model
      db_connects("#{@ultra_company_db_model.db_style}","#{@ultra_company_db_model.db_con}","#{@ultra_company_db_model.db_user}","#{@ultra_company_db_model.db_password}")
      #搜索条件拼接
      @sql = @current_model.str_sql
      #搜索配置截取
      sub_search
      #钻取连接配置
      sub_link
      #获取展示标题
      @freed_report_name=@current_model.name

      @my_params.each_with_index do |m,x|
      has_compare_option?(@sql,m[3],m[0],m[2],m[5],params["#{m[0]}#{x}"],m,x)
      end
       #算取查询个数
      if params[:page]
        @count_sum=@dbh.execute(count_message(@sql))
        @count_sum.each do |report|
              report.each do |a|
                 @count_sum_num=a.to_i
              end
        end
      end
      #执行报表sql查询
      @cullent_attributes=@dbh.execute(content_message(@sql))
      @columns=@cullent_attributes.column_names  #获取报表展示字段
      #@cullent_attributes=[] unless params[:remark]
         @cullent_attributes.each do |report|
            b={}
            report.each_with_index do |a , x|
               b[@columns[x]]=a.to_s
            end
            @ult_freed_reports<<b   #组装结果集
            @page_ult_freed_reports<<b
         end
      #return @ult_freed_reports
  end

  def sub_search #截取查询条件--李江锋ljf--2013-11-12  0为name，1为中文标注，2为符号，3为标签，4为取值  例子：name/名称/=/select/[["李","1"],["江","2"],["锋","3"]]&name/名称/=/select/[["李","1"],["江","2"],["锋","3"]]
      @my_params=[]
      if @current_model&&@current_model.form_title&&@current_model.form_title!=""
      @my_params_first=@current_model.form_title.split("￥")
      @my_params_first.each { |f| @my_params<<f.split("#")}
      end
  end

  def sub_link
      @my_links={}
      if @current_model&&@current_model.report_link&&@current_model.report_link!=""
      @my_params_first=@current_model.report_link.split("￥")
      @my_params_first.each { |f| @my_links<<@my_links[f.split('|')[0]]=f.split('|')[1].to_s }
      end
  end

  def has_compare_option?(content,style,name,singer,check,option,m=nil,x=nil)    #style有大于、小于、等于、like--李江锋ljf--2013-11-12
    check_option=(option!='pk'? (singer=="like"? "'%#{option}%'" : "'#{option}'"): "''")
    unless (check.nil? || check.empty?)
      if style=="time"
        if @current_model.time_gran=="hour"
           option=Time.now.yesterday.strftime('%Y-%m-%d %H:%M:%S') if option.nil? || option.empty? || option==['']
           where_con = (option.nil? || option.empty? || option==['']) ? "" : " and to_date(to_char(#{name},'yyyy-mm-dd hh24:mi:ss'),'yyyy-mm-dd hh24:mi:ss') #{singer} to_date('#{option}','yyyy-mm-dd hh24:mi:ss')"
        else
           option=Time.now.yesterday.strftime('%Y-%m-%d') if option.nil? || option.empty? || option==['']
           where_con = (option.nil? || option.empty? || option==['']) ? "" : " and to_date(to_char(#{name},'yyyy-mm-dd'),'yyyy-mm-dd') #{singer} to_date('#{option}','yyyy-mm-dd')"
        end
      elsif style=="checkbox"
        where_con = (option.nil? || option.empty? || option==['']) ? "" : " and #{name} #{singer} "+ check_option
      else
        where_con = (option.nil? || option.empty? || option==['']) ? "" : " and #{name} #{singer} "+ check_option
      end
      message = content
       #替换搜索条件
      message.gsub!(check, where_con)
      #替换搜索配置参数
      if m
         message.gsub!("￥#{m[1]}",params["#{m[0]}#{x}"]?params["#{m[0]}#{x}"] :Time.now.yesterday.strftime('%Y/%m/%d') ) if message.include?"￥#{m[1]}"
      end
      @sql=message
      return @sql
      end
  end

  def model_search(reportid)  #选择报表模版
     if params[:time_gran]&&params[:area_gran]
         @select_model=FreedReport::UltReportModel.find(reportid)
         @current_model=FreedReport::UltReportModel.find(:first,:conditions => ["name = ? and time_gran = ? and area_gran = ?",@select_model.name,params[:time_gran],params[:area_gran]])
         @current_model=FreedReport::UltReportModel.find(reportid) unless @current_model
     else
         @current_model=FreedReport::UltReportModel.find(reportid)
     end
  end

  def content_message (str_sql)   #报表模版sql替换加工
      sort=params[:sort]?" order by "+"'"+"#{params[:sort]}"+"'"+"  #{params[:order]}":""
      message = str_sql+sort
     #替换区域范围查找条件参数--吉林日志定制
      area_check
      if @province_domain!=@current_domain&&!params[:cityare]
       @area_sql_str=" and c.cityid =#{@current_domain_id}"
      end
      message.gsub!("@area_sql_str@", @area_sql_str) if message.include? "@area_sql_str@"
      #用户权限sql级别判断
      #---------------------
      #current_domain=" and c.nodedn like '%#{@current_user.domain.base}'"
      #message.gsub!("@domain@", current_domain) if message.include?"@domain@"
      #--------------------
      #快速校验数据SQL正确性
      message="select o.* from ("+message+")o where 1=2" if !params[:remark]&&!params[:page]&&!params[:format]
      message="SELECT * FROM (  SELECT A.*, ROWNUM RN  FROM ("+message+")A
              WHERE ROWNUM <= #{(params[:page].to_i)*30})
              WHERE RN >= #{(params[:page].to_i-1)*30+1}" if params[:page]
      message
  end

   def count_message (str_sql)   #报表模版分页总数查找
     message=str_sql
     #替换区域范围查找条件参数--吉林日志定制
      area_check
     if @province_domain!=@current_domain&&!params[:cityare]
       @area_sql_str=" and c.cityid =#{@current_domain_id}"
     end
      message.gsub!("@area_sql_str@", @area_sql_str) if message.include? "@area_sql_str@"
      #用户权限sql级别判断
      #---------------------
      #current_domain=" and c.nodedn like '%#{@current_user.domain.base}'"
      #message.gsub!("@domain@", current_domain) if message.include?"@domain@"
      #--------------------
      message="SELECT COUNT(*) AS COUNT_NUM FROM ("+message+")"
      message
  end


  def area_check
    #区域范围条件判断
     unless params[:area_gran]=="province"
        if params[:acare]&&params[:acare][:myac_ids]&&params[:area_gran]!="city"
              acstr=""
              for ac in params[:acare][:myac_ids]
                 myac="'"+ac.to_s+"'"
                 myac+="," unless ac==params[:acare][:myac_ids].last
                 acstr+= myac
              end
              @area_sql_str = " and c.ac in ("+acstr+")"
        elsif ((params[:area_gran]=="city"&&params[:acare])||!params[:acare])&&params[:cityare]&&params[:cityare][:mycity_ids]
              citystr=""
              for city in params[:cityare][:mycity_ids]
                 mycity="'"+city.to_s+"'"
                 mycity+="," unless city==params[:cityare][:mycity_ids].last
                 citystr+= mycity
              end
              @area_sql_str = " and c.cityid in ("+citystr+")"
        elsif !params[:acare]&&!params[:cityare]&&params[:myare]
              @area_sql_str = ""
        else
              @area_sql_str = ""
        end
    end
  end



  DbStyleHashs = {"mysql"=>"DBI:Mysql","oracle"=>"DBI:OCI8"} #由dbi扩充支持其他库类

def db_connects(style=nil,d=nil,u=nil,p=nil) #数据库参数获取
      @userName = u
      @password = p
      database =  d
      @database = "#{DbStyleHashs[style]}:#{database}"
      @dbh = DBI.connect(@database,@userName,@password)
  end

  def excute_the_sql(params) #自定义报表读取模版--2013-10--李江锋ljf---已淘汰此法
    reportid=params[:report_id].to_i
    #数据库连接
    model_search(reportid)
    @model_con= @current_model.model_style.constantize.connection()
    #搜索条件拼接
    @where_con = ""
    sub_search
    @my_params.each do |m|
    has_compare_option?("#{m[0]}","#{m[2]}",params["#{m[0]}".to_sym]) if params["#{m[0]}".to_sym]&&params["#{m[0]}".to_sym]!=""&&params["#{m[0]}".to_sym]!=[""]
    end
    #获取展示标题、字段
    @columns=@current_model.show_title.split("，")
    @freed_report_name=@current_model.name
    #执行报表sql查询
    if params[:remark]
    @ult_freed_reports=@model_con.select_all content_message(@current_model.str_sql,@where_con)
    else
    @ult_freed_reports=[]
    end
    return @ult_freed_reports
  end

end
