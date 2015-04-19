# 实现数据库连接、模版调用解析。
#支持自定义数据源(支持oracle、mysql等/可由dbi扩充支持)、自定义sql脚本、自定义条件查询、自动生成导航连接。

module DbSql
  require 'dbi'#获得dbi的数据库连接支持gem库包

  def excute_other_sql  #报表统一解析查询接口 2014-7-10版--李江锋ljf
     #获取报表id
     reportid=params[:report_id].to_i
     #定义返回数组
     @ult_freed_reports=[]
     @page_ult_freed_reports=[]
      #选择模版
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
      #搜索条件遍历赋值
      @params_url=""
      @my_params.each_with_index do |m,x|
      #--等同字段互换start---------params[:my_params]为钻取传过来的参数-----
      if params["T.DAYTIME#{x}"]||(params[:my_params]&&params["my_params"]["T.DAYTIME#{x}"])
         params["#{m[0]}#{x}"]=params["T.DAYTIME#{x}"]||params["my_params"]["T.DAYTIME#{x}"]
      elsif params["T.WEEKTIME#{x}"]||(params[:my_params]&&params["my_params"]["T.WEEKTIME#{x}"])
         params["#{m[0]}#{x}"]=params["T.WEEKTIME#{x}"]||params["my_params"]["T.WEEKTIME#{x}"]
      elsif params["T.MONTHTIME#{x}"]||(params[:my_params]&&params["my_params"]["T.MONTHTIME#{x}"])
         params["#{m[0]}#{x}"]=params["T.MONTHTIME#{x}"]||params["my_params"]["T.MONTHTIME#{x}"]
      elsif params[:my_params]&&params["my_params"]["#{m[0]}#{x}"]
         params["#{m[0]}#{x}"]=params["my_params"]["#{m[0]}#{x}"]
      end
      #--等同字段互换end----------------------
      #图表异步传接数据。
      @params_url+=m[1].to_s+'|'+params["#{m[0]}#{x}"].to_s+'￥'
      has_compare_option?(@sql,m[3],m[0],m[2],m[5],params["#{m[0]}#{x}"],m,x)
      end
      #算取查询结果条数
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
      #获取报表展示字段
      @columns=@cullent_attributes.column_names
      #隐藏字段获取
      @hidden_columns=(@current_model.show_title&&@current_model.show_title!="") ? @current_model.show_title.split("|") :[]
      #初始访问，返回值置空控制。
      #@cullent_attributes=[] unless params[:remark]
      #组装结果集
         @cullent_attributes.each do |report|
            b={}
            report.each_with_index do |a , x|
               b[@columns[x]]=a.to_s
            end
            @ult_freed_reports<<b
            @page_ult_freed_reports<<b
         end
  end

  def sub_search
      #截取查询条件--李江锋ljf--2013-11-12  0为name，1为中文标注，2为符号，3为标签，4为取值  例子：name/名称/=/select/[["李","1"],["江","2"],["锋","3"]]&name/名称/=/select/[["李","1"],["江","2"],["锋","3"]]
      @my_params=[]
      if @current_model&&@current_model.form_title&&@current_model.form_title!=""
      @my_params_first=@current_model.form_title.split("￥")
      @my_params_first.each { |f| @my_params<<f.split("#")}
      end
  end

  def sub_link
      #钻取连接获取
      @my_links={}
      if @current_model&&@current_model.report_link&&@current_model.report_link!=""
      @my_params_first=@current_model.report_link.split("￥")
      @my_params_first.each { |f| @my_links<<@my_links[f.split('|')[0]]=f.split('|')[1] }
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

  def model_search(reportid)
     #选择报表模版
     if params[:time_gran]&&params[:area_gran]
         @select_model=FreedReport::UltReportModel.find(reportid)
         @current_model=FreedReport::UltReportModel.find(:first,:conditions => ["name = ? and time_gran = ? and area_gran = ?",@select_model.name,params[:time_gran],params[:area_gran]])
         @current_model=FreedReport::UltReportModel.find(reportid) unless @current_model
     else
         @current_model=FreedReport::UltReportModel.find(reportid)
     end
  end

  def content_message (str_sql)
     #报表模版sql替换加工
      sort=params[:sort]?" order by "+"'"+"#{params[:sort]}"+"'"+"  #{params[:order]}":""
      message = str_sql+sort
     #替换区域范围查找条件参数--吉林日志定制
      area_check
      to_report_detail(message) if params[:my_params]&&params[:my_values]
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
      #添加分页查询
      message="SELECT * FROM (SELECT A.*, ROWNUM RN  FROM ("+message+")A
              WHERE ROWNUM <= #{(params[:page].to_i)*30})
              WHERE RN >= #{(params[:page].to_i-1)*30+1}" if params[:page]
      message
  end



  def to_report_detail(message)
    #撰取类报表参数替换---2014-7-15--李江锋---ljf
    #搜索参数
    @my_params_detail=params[:my_params]
    #行列参数
    @my_values=params[:my_values]
    if @my_values
      @my_values.each do|k,v|
        message.gsub!("￥#{k}", v) if message.include? "￥#{k}"
      end
    end
    if @my_params_detail&&@my_params_detail!=""
       @my_params_first=@my_params_detail.split("￥")
       @my_params_first.each { |f| message.gsub!("￥#{f.split("|")[0]}", "#{f.split("|")[1]}")}
    end
  end

   def count_message (str_sql)   #报表模版分页总数查找
     message=str_sql
     #替换区域范围查找条件参数--吉林日志定制
     area_check
     to_report_detail(message) if params[:my_params]&&params[:my_values]
     if @province_domain!=@current_domain&&!params[:cityare]
       @area_sql_str=" and c.cityid =#{@current_domain_id}"
     end
      message.gsub!("@area_sql_str@", @area_sql_str) if message.include? "@area_sql_str@"
      #统计返回查询总数
      message="SELECT COUNT(*) AS COUNT_NUM FROM ("+message+")"
      message
  end


  def area_check
    #吉林日志报表区域范围条件判断
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

end
