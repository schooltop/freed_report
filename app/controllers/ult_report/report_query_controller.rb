class UltReport::ReportQueryController < ApplicationController  

  def columns_after_add_unit
    name_units = Rms::PerfType.index_units
    # 因为性能报表导出已经没有对结果集进行数据格式化处理，所以需要去除表头单位为'%'的。
    if params[:reporttype] == 1
      name_units.delete_if{|k,v| v == "%"}
    end
    @schema.map{|column| column + (name_units[column].nil? ? "" : "(#{name_units[column]})")} 
  end

  def format_data_for_csv options={}
    option = {
      :starTime => nil,
      :endTime => nil, 
      :datelist => nil 
    }
    option.merge!(options)
    @schema = @result_set[:data][:schema]
    @result = @result_set[:data][:result]
    drop_or_not = @result.count > 0 ? !@result.first["R"].nil? : false
    result_count = @result.first.count if drop_or_not
    # logger.info("drop?#{drop_or_not}")

    csv_start = Time.now
    require "fastercsv"
    data = FasterCSV::generate do |csv|
      csv << ["报表分析时间范围：", "#{option[:starTime]}", "#{option[:endTime]}"] if option[:starTime]
      csv << ["报表分析时间范围：", "#{option[:datelist]}"] if option[:datelist] 
      csv << columns_after_add_unit
      @result.each do |record|
        if record.is_a? Hash
          array_record = []
          @schema.each { |col|
            if col.include?("占比")
              value = record[col].nil? ? "":'%.2f' % (record[col] * 100)+"%"
              array_record << value
            else
              array_record << record[col]
            end
          }
          csv << array_record
        else
          record.delete_at(result_count - 1) if drop_or_not
          csv << record
        end
      end
    end
    logger.info("#{Time.now - csv_start}s")
    data = data.to_iso

    # csv_start = Time.now
    # data = []
    # data << ["报表分析时间范围：","#{option[:starTime]} " , "至 #{option[:endTime]}\r\n"].join(",") if option[:starTime]
    # data << ["报表分析时间范围：",option[:datelist],"\r\n"].join(",") if option[:datelist]
    # data << columns_after_add_unit.join(',') << "\r\n"
    # @result.each do |record|
    #   data << @schema.map {|key| record[key].to_s << ","} << "\r\n"
    # end
    # logger.info("#{Time.now - csv_start}s")
    # data = data.join.to_iso
    time = Time.now.strftime("%y-%m-%d-%H-%M-%S")
    [data, time] 
  end

  #根据模板编号取得统计结果中的数据用来生成CHART
  #params:
  #id
  #chart_seq
  #kpi_name
  def chart
    # template = UltReport::ReportTemplateSet.find(:first,:conditions=>{:template_id=>params[:id],:chart_seq =>params[:chart_seq]})
    template = UltReport::ReportTemplateSet.find(:first,:conditions=>{:template_id=>params[:id],:id=>params[:chart_seq]})
    @chart_template = template
    chart_set = get_chart_set(template)
    @chart_result = chart_set[:data][:result]
    @color= []
    result = @chart_result
    # p "========================="
    #           p result
    y_col = params[:kpi_name].upcase
    x_col = @chart_template.x_col
    group_col = @chart_template.group_col
    if group_col
      group_col = group_col.split(",")
    else
      group_col = ""
    end
    @csv_data = ""
    # p x_col
    #     p y_col
    #     p @chart_template.group_col
    case @chart_template.chart_type
    when 1 :
        @group_col = []
      result1 = []
      x_names = []
      result.each do |e|
        gcol = ""
        group_col.each do |g|
          gcol << "_"  unless gcol.blank?
          gcol << (e[g].is_a?(Time) ? e[g].strftime("%Y-%m-%d") : e[g].to_s)
        end
        @group_col << {:human_name=>gcol,:fill=>0,:width=>2,:color=>""}
        e[:groupby]= gcol
        result1 << e
        x_names << e[x_col]
      end
      x_names = x_names.uniq
      @group_col = @group_col.uniq
      @metric = Metric.new("","","100%x350","EDFBFC",@group_col)
      x_names.each do |g|
        result1.each_index do |i|
          e = result1[i]
          x_name = g.is_a?(Time) ? g.strftime("%Y-%m-%d") : g
          @csv_data << "\n" << x_name.to_s  if i==0
          @csv_data << ";"  << e[y_col].to_s.delete("%")  if  g==e[x_col]      
        end
      end
      # p @csv_data
      #                p @metric
      #                p @group_col
      render :partial => "templates/amline1",:locals => {:csv_data=>@csv_data ,:metric=>@metric}
    when 2 :
        @group_col = []
      result.each do |e|
        gcol = ""
        group_col.each do |g|
          gcol << "_"  unless gcol.blank?
          gcol << (e[g].is_a?(Time) ? e[g].strftime("%Y-%m-%d") : e[g].to_s)
        end
        @group_col << gcol
      end
      @group_col = @group_col.uniq
      @column = (result.collect{ |v| v[x_col] }).uniq
      @column.each do |e|
        @csv_data << "\n" << e.to_s
        result.each do |r|
          if r[x_col].to_s==e.to_s
            @csv_data << ";" << r[y_col].to_s.delete("%")
          else
            next
          end
        end
      end 
      render :partial => "templates/amcolumn", :locals => {:csv_data => @csv_data, :unit => ""}
    when 3 :
        result.each{ |e|
        @csv_data  << "\n" << e[x_col].to_s.delete("%") << ";" << e[y_col].to_s.delete("%")
        @unit = ""
      }
      render :partial => "templates/ampie", :locals => {:csv_data => @csv_data, :unit => ""}
    end
  end

  #取得统计结果的schema信息
  #  def get_schema
  #    template = Rms::ReportTemplate.find(params[:id])
  #    @id = params[:id]
  #    begin
  #      if template.report_type == 1 #性能模板
  #        @result_set = perf_statistic(template)
  #      else
  #        @result_set = alarm_statistic(template)
  #      end
  #      @schame = {:schema => @result_set[:data][:schema]}.to_json
  #    rescue
  #      @schame = false
  #    end
  #  end

  #获得指标列表

  def get_kpilist_data
    params[:chart_seq] = params[:chart_seq]?params[:chart_seq]:1
    netlocGrnas = UltReport::ReportTemplate.find(params[:id])
    kpilist = netlocGrnas.kpilist.to_s.split(",")
    ids_param = {}
    ids_param = {:id => kpilist } if kpilist.size > 0
    if (netlocGrnas.report_type == 1)||(netlocGrnas.report_type == 3)
      netlocGran = netlocGrnas.netloc_gran
      if netlocGran < 3
        if kpilist.blank?
          data = Rms::PerfType.find(:all,:conditions => ["is_town = 1 "], :order=>'id')
        else
          data = Rms::PerfType.find(:all,:conditions => ["(is_town = 1 ) and id in (#{kpilist.join(",")})"], :order=>'id')
        end
      elsif netlocGran > 2 && netlocGran < 5  
        data = Rms::PerfType.find(:all,:conditions => {:is_port => 1}.update(ids_param),:order=>'id')
      elsif netlocGran == 5
        data = Rms::PerfType.find(:all,:conditions => {:is_port => 1}.update(ids_param),:order=>'id')
      elsif (netlocGran == 6)or(netlocGran == 7)
        data = Rms::PerfType.find(:all,:conditions=>{:is_floor => 1}.update(ids_param),:order=>'id')
      elsif netlocGran == 8
        data = Rms::PerfType.find(:all,:conditions=>{:is_ac => 1}.update(ids_param),:order=>'id')
      elsif netlocGran == 9
        data = Rms::PerfType.find(:all,:conditions=>{:is_sw => 1}.update(ids_param),:order=>'id')
      elsif netlocGran == 10
        data = Rms::PerfType.find(:all,:conditions=>{:is_swport => 1}.update(ids_param),:order=>'id')
      elsif netlocGran == 11
        data = Rms::PerfType.find(:all,:conditions=>["is_ap = 1 and id in (#{kpilist})"],:order=>'id')
      else
        data = Rms::PerfType.find(:all,:order=>'id')
      end
    elsif (netlocGrnas.report_type == 2) #告警报表
      dicGroup = netlocGrnas.dic_group
      if (not dicGroup.nil?)&&
          (dicGroup.upcase.include?('ALARM_TYPE')||
            dicGroup.upcase.include?('ALARM_ALIAS')||
            dicGroup.upcase.include?('SEVERITY_NAME'))
        data = Rms::PerfType.find_by_sql("select 1 id,'告警数量' name_cn from dual
        union select 2 id,'告警设备数量' name_cn from dual
        union select 3 id,'告警修复数' name_cn from dual
        union select 4 id,'告警及时修复数' name_cn from dual
        union select 5 id,'及时修复率' name_cn from dual")
      else
        data = Rms::PerfType.find_by_sql("select 1 id,'告警数量' name_cn from dual
        union select 2 id,'告警设备数量' name_cn from dual
        union select 3 id,'所有设备数量' name_cn from dual
        union select 4 id,'设备故障率' name_cn from dual
        union select 5 id,'告警修复数' name_cn from dual
        union select 6 id,'告警及时修复数' name_cn from dual
        union select 7 id,'及时修复率' name_cn from dual")
      end
    end

    @kpilist_data = data

  end

  #配置数据统计
  #POST
  def config_statistic(template)
    option = template.attributes
    option["page"] = params[:page]
    option["page"] ||= 0
    option["size"] = @page_size

    db_read_str = 'BEGIN WLAN_CONFIG_QRY(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?); END;'
    stat_config_procedure(db_read_str,option)
  end

  #常用报表中改过的
  # def perf_statistic(template)
  #   option = template.attributes
  #   option["localip"] = request.remote_ip
  #   sort = parse_sort params[:sort]
  #   option["sort_col"] = sort[:name]
  #   option["sort_dir"] = sort[:direction] || "ASC"
  #   option["page"] = params[:page]
  #   option["page"] ||= 0
  #   option["size"] = @page_size
  #   db_read_str = 'BEGIN WLAN_PERF_QRY(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?); END;'
  #   stat_procedure(db_read_str,option)
  # end

  #性能数据统计
  #POST
  #参数template :ReportTemplate对象实例
  def perf_statistic(template)
    option = template.attributes
    option["localip"] = request.remote_ip
    sort = parse_sort params[:sort]
    option["sort_col"] = sort[:name]
    option["sort_dir"] = sort[:direction] || "ASC"
    option["page"] = params[:page]
    option["page"] ||= 0
    option["size"] = @page_size
    if template.report_type == 1
      db_read_str = 'BEGIN ULTRA_COMPANY_PERF_QRY(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?); END;'
      stat_procedure(db_read_str,option)
    elsif template.report_type ==3
      db_read_str = 'BEGIN WLAN_PERF_CASE_QRY(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?); END;'
      stat_case_procedure(db_read_str,option)
    end
    
  end
  
  
  #参数template :ReportTemplate，获得Chart数据
  def get_chart_set(template)
    sort = parse_sort params[:sort]
    option = template.attributes.merge(template.report_template.attributes)
    option["localip"] = request.remote_ip
    option["sort_col"] = sort[:name]
    option["sort_dir"] = sort[:direction] || "ASC"
    option["y_col"] = params[:kpi_name]
    db_read_str = 'BEGIN WLAN_GET_RECORD_FOR_CHART(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?); END;'
    chart_procedure(db_read_str,option)
  end
  
  #执行存储过程=>性能统计存储过程
  #  /** 参数含义
  #       index_sys :指标体系  1：wlan  2：
  #       netloc_gran :查询粒度 0:省1:市2:郊县3:区局4:分局5:热点6:楼宇7:楼层8:AC
  #                   9:交换机10:交换机端口11:AP12:SSID
  #       netloc :数据筛选条件，例如：'((cityid=1)or(branch=2)or(device_type=5))'
  #       filter_con : 指标筛选条件
  
  #  如果是专案：则netloc_gran和netloc的参数含义不一样
  #       netloc_gran :查询粒度 0:所有维度聚合 1：专案组 2：AP
  #       netloc :专案组编号，例如：'123,'或'123,234,345,'
  
  #       dic_group : 数据字典分组，例如：'device_type,device_manu'...
  #       time_type : 时间类型，1：连续时间 2：间断时间
  #       startdate : time_type =1时需要填
  #       enddate : time_type =1时需要填
  #       date_list : time_type =2时需要填，例如：'2008-5-4,2008-5-6,2008-5-10'...
  #       time_gran :时间维查询方式：0=季，1=月，2=周，3=日，4=时，
  #                                  5=全时段 6=仅按小时聚合 7=所有时间聚合
  #                                  8=”仅按小时聚合并取最忙时指标“，则需要先按6统计
  #       busytime :忙时，-1=系统忙时，-2=全时段,(0..24) -3=指定时段 -4=设备忙时 -5=早晚忙时
  #       hourlist :具体时段
  #       cityid   :地市编号
  #       kpilist  :指标列表
  #       userid   :用户编号
  #       guid     :查询唯一标识
  #       localip  :本地IP地址
  #       top_N    :topN的数值，比如100、200...
  #       p_order  :排序SQL，例如：' order by 日期,时段,热点,APID,无线侧接收字节数...'
  #       p_curPage   :当前页
  #       p_pageSize  :每页显示记录条数
  #       p_totalRecords  :总记录数
  #       p_totalPages    :总页数
  #       p_cursor1 :返回游标数据
  #  **/

  def stat_procedure(db_read_str, option = nil)
    date_format = '%Y-%m-%d'
    start_date = option["startdate"]
    end_date = option["enddate"]
    option["userid"]=@current_user.id  if option["userid"].blank?
    with_db_ora do |dbh|
      sth_db = dbh.prepare(db_read_str)
      sth_db.bind_param(1, option["index_sys"])
      sth_db.bind_param(2, option["netloc_gran"])
      sth_db.bind_param(3, option["netloc"])
      sth_db.bind_param(4, option["index_filter"])
      sth_db.bind_param(5, option["dic_group"])
      sth_db.bind_param(6, option["time_type"])
      sth_db.bind_param(7, start_date.strftime(date_format)) #"to_date('#{start_date.strftime(date_format)}','yyyy-mm-dd')"
      sth_db.bind_param(8, end_date.strftime(date_format)) #"to_date('#{end_date.strftime(date_format)}','yyyy-mm-dd')"
      sth_db.bind_param(9, option["datelist"])
      sth_db.bind_param(10, option["time_gran"])
      sth_db.bind_param(11, option["busytime"])
      sth_db.bind_param(12, option["hourlist"])
      sth_db.bind_param(13, option["cityid"])
      sth_db.bind_param(14, option["kpilist"])
      sth_db.bind_param(15, option["userid"])
      sth_db.bind_param(16, option["id"])
      sth_db.bind_param(17, option["localip"])
      if option["is_topn"] == 1 && !option["top_n"].blank? && !option["topn_kpi"].blank?
        sth_db.bind_param(18, option["top_n"])
      else
        sth_db.bind_param(18, nil)
      end
      #分页参数
      if option["sort_col"]
        option["sort_col"] = option["sort_col"][0, option["sort_col"].index("(")] if option["sort_col"].include?("(")
        orderStr = 'order by '+option["sort_col"]+' '+option["sort_dir"]
      elsif option["is_topn"] == 1 && !option["topn_kpi"].blank?
        if option["sort_type"] ==1
          sortStr = ' asc'
        else
          sortStr = ' desc'
        end
        orderStr = 'order by '+option["topn_kpi"]+sortStr
      else
        if option["sort_dir"].nil?
          if option["time_gran"] == 4
            orderStr = "order by #{option["sort_dir"]},日期,时段"
          elsif option["time_gran"] == 3
            orderStr = "order by #{option["sort_dir"]},日期"
          elsif option["time_gran"] == 2
            orderStr = "order by #{option["sort_dir"]}"
          elsif option["time_gran"] == 1
            orderStr = "order by #{option["sort_dir"]},月份"
          elsif option["time_gran"] == 0
            orderStr = "order by #{option["sort_dir"]},季度"
          end
        else
          orderStr = ''
        end
      end
      sth_db.bind_param(19, orderStr)
      sth_db.bind_param(20, option["page"])
      sth_db.bind_param(21, option["size"])
      sth_db.bind_param(22, 9)
      sth_db.bind_param(23, 3)
      sth_db.bind_param(24, DBI::StatementHandle)#to bind ref cursor as DBI::StatementHandle
      sth_db.execute
      @total = sth_db.func(:bind_value, 22)
      sth = sth_db.func(:bind_value, 24)
      @schema = sth.column_info
      @results = sth.fetch_many(150000)
    end
    start = Time.now
    result_set = Array.new
    schema_info = Array.new
    perf_types = Rms::PerfType.find(:all, :conditions => {:index_sys => 1}, :order=>'id')    

    @schema.each do |s|
      schema_info << s["name"] unless s["name"].downcase == 'r'
    end
    
    {:total => @total, :data => {:schema => schema_info, :result => @results}}
  end

  #执行存储过程=>专案统计存储过程
  def stat_case_procedure(db_read_str, option = nil)
    date_format = '%Y-%m-%d'
    start_date = option["startdate"]
    end_date = option["enddate"]
    option["userid"]=@current_user.id  if option["userid"].blank?
    with_db_ora do |dbh|
      sth_db = dbh.prepare(db_read_str)
      sth_db.bind_param(1, option["index_sys"])
      sth_db.bind_param(2, option["netloc_gran"])
      sth_db.bind_param(3, option["netloc"])
      sth_db.bind_param(4, option["dic_group"])
      sth_db.bind_param(5, option["time_type"])
      sth_db.bind_param(6, start_date.strftime(date_format)) #"to_date('#{start_date.strftime(date_format)}','yyyy-mm-dd')"
      sth_db.bind_param(7, end_date.strftime(date_format)) #"to_date('#{end_date.strftime(date_format)}','yyyy-mm-dd')"
      sth_db.bind_param(8, option["datelist"])
      sth_db.bind_param(9, option["time_gran"])
      sth_db.bind_param(10, option["busytime"])
      sth_db.bind_param(11, option["hourlist"])
      sth_db.bind_param(12, option["cityid"])
      sth_db.bind_param(13, option["kpilist"])
      sth_db.bind_param(14, option["userid"])
      sth_db.bind_param(15, option["id"])
      sth_db.bind_param(16, option["localip"])
      if option["is_topn"] == 1 && !option["top_n"].blank? && !option["topn_kpi"].blank?
        sth_db.bind_param(17, option["top_n"])
      else
        sth_db.bind_param(17, nil)
      end
      #分页参数
      if option["sort_col"]
        option["sort_col"] = option["sort_col"][0, option["sort_col"].index("(")] if option["sort_col"].include?("(")
        orderStr = 'order by '+option["sort_col"]+' '+option["sort_dir"]
      elsif option["is_topn"] == 1 && !option["topn_kpi"].blank?
        if option["sort_type"] ==1
          sortStr = ' asc'
        else
          sortStr = ' desc'
        end
        orderStr = 'order by '+option["topn_kpi"]+sortStr
      else
        if option["sort_dir"].nil?
          if option["time_gran"] == 4
            orderStr = "order by #{option["sort_dir"]},日期,时段"
          elsif option["time_gran"] == 3
            orderStr = "order by #{option["sort_dir"]},日期"
          elsif option["time_gran"] == 2
            orderStr = "order by #{option["sort_dir"]}"
          elsif option["time_gran"] == 1
            orderStr = "order by #{option["sort_dir"]},月份"
          elsif option["time_gran"] == 0
            orderStr = "order by #{option["sort_dir"]},季度"
          end
        else
          orderStr = ''
        end
      end
      sth_db.bind_param(18, orderStr)
      sth_db.bind_param(19, option["page"])
      sth_db.bind_param(20, option["size"])
      sth_db.bind_param(21, 9)
      sth_db.bind_param(22, 3)
      sth_db.bind_param(23, DBI::StatementHandle)#to bind ref cursor as DBI::StatementHandle
      sth_db.execute
      @total = sth_db.func(:bind_value, 21)
      sth = sth_db.func(:bind_value, 23)
      @schema = sth.column_info
      @results = sth.fetch_many(150000)
    end
    start = Time.now
    result_set = Array.new
    schema_info = Array.new
    perf_types = Rms::PerfType.find(:all, :conditions => {:index_sys => 1}, :order=>'id')

    @schema.each do |s|
      # kpi_unit = ""
      # perf_types.each do |p|
      #   if s["name"]==p.name_cn
      #     kpi_unit = p.name_unit.nil? ? "": "("+p.name_unit+")"
      #   end
      # end
      # schema_info << s["name"]+kpi_unit unless s["name"].downcase == 'r'
      schema_info << s["name"] unless s["name"].downcase == 'r'
    end

    {:total => @total, :data => {:schema => schema_info, :result => @results}}
  end

  #执行存储过程=>资源统计存储过程
  #  /** 参数含义
  #       netloc_gran :查询粒度 0:省1:市2:郊县3:区局4:分局5:热点
  #       netloc :数据筛选条件，例如：'((cityid=1)or(branch=2)or(device_type=5))'
  #       dic_group : 数据字典分组，例如：'device_type,device_manu,device_kind'...
  #       date_list : 例如：'2008-5-4,2008-5-6,2008-5-10'...
  #       cityid   :地市编号
  #       p_curPage   :当前页
  #       p_pageSize  :每页显示记录条数
  #       p_totalRecords  :总记录数
  #       p_totalPages    :总页数
  #       p_cursor1 :返回游标数据
  #  **/ 需要修改
  def stat_config_procedure(db_read_str, option = nil)
    date_format = '%Y-%m-%d'
    start_date = option["startdate"]
    end_date = option["enddate"]
    with_db_ora do |dbh|
      sth_db = dbh.prepare(db_read_str)
      sth_db.bind_param(1, option["netloc_gran"])
      sth_db.bind_param(2, option["netloc"])
      sth_db.bind_param(3, option["device_class"])
      sth_db.bind_param(4, option["dic_group"])
      sth_db.bind_param(5, start_date.strftime(date_format)) #"to_date('#{start_date.strftime(date_format)}','yyyy-mm-dd')"
      sth_db.bind_param(6, end_date.strftime(date_format)) #"to_date('#{end_date.strftime(date_format)}','yyyy-mm-dd')"
      sth_db.bind_param(7, option["cityid"])
      sth_db.bind_param(8, option["page"])
      sth_db.bind_param(9, option["size"])
      sth_db.bind_param(10, 9)
      sth_db.bind_param(11, 3)
      sth_db.bind_param(12, DBI::StatementHandle)#to bind ref cursor as DBI::StatementHandle
      sth_db.execute
      
      @total = sth_db.func(:bind_value, 10)
      sth = sth_db.func(:bind_value, 12)
      @schema = sth.column_info
      @results = sth.fetch_all
      #      dbh.disconnect
    end
    schema_info = Array.new
    @schema.each do |s|
      schema_info << s["name"] unless s["name"].downcase == 'r'
    end
    {:total => @total, :data => {:schema => schema_info, :result => @results}}
  end

  #执行获得Chart数据的存储过程
  #  /** 参数含义
  #       index_sys :指标体系  1：wlan  2：
  #       report_type :报表类型 1：性能 2：告警 3：专案
  #       netloc_gran :查询粒度 0:省1:市2:郊县3:区局4:分局5:热点6:楼宇7:楼层8:AC
  #                   9:交换机10:交换机端口11:AP12:SSID
  #       dic_group : 数据字典分组，例如：'device_type,device_manu'...
  #       time_gran :时间维查询方式：0=季，1=月，2=周，3=日，4=时，
  #                                  5=全时段 6=仅按小时聚合 7=所有时间聚合
  #                                  8=”仅按小时聚合并取最忙时指标“，则需要先按6统计
  #       kpilist  :指标列表
  #       y_column :纵轴的字段，（有线侧接收包数/无线侧流量...），只能单选
  #       x_column :横轴的字段，（日期/时段/区县/热点/交换机...），可以多个组合
  #       group_column :分组条件，（日期/时段/区县/热点/交换机...），可以多个组合
  #       userid   :用户编号
  #       guid     :查询唯一标识，可以用模板ID来替代
  #       localip  :本地IP地址
  #       top_n    :topN的数值，比如100、200...
  #       p_order  :排序SQL，例如：' order by 有线侧接收包数 desc'
  #       p_curPage   :当前页
  #       p_cursor1 :返回游标数据
  #  **/
  def chart_procedure(db_read_str, option = nil)
    option["userid"]=@current_user.id  if option["userid"].blank?
    with_db_ora do |dbh|
      sth_db = dbh.prepare(db_read_str)
      sth_db.bind_param(1, option["index_sys"])
      sth_db.bind_param(2, option["report_type"])
      sth_db.bind_param(3, option["netloc_gran"])
      sth_db.bind_param(4, option["dic_group"])
      sth_db.bind_param(5, option["time_gran"])
      sth_db.bind_param(6, option["kpilist"])
      sth_db.bind_param(7, option["y_col"])
      sth_db.bind_param(8, option["x_col"])
      sth_db.bind_param(9, option["group_col"])
      sth_db.bind_param(10, option["userid"])
      sth_db.bind_param(11, option["id"])
      sth_db.bind_param(12, option["localip"])
      if option["is_topn"] == 1 && !option["top_n"].blank? && !option["topn_kpi"].blank?
        sth_db.bind_param(13, option["top_n"])
      else
        sth_db.bind_param(13, nil)
      end
      #分页参数
      if option["sort_col"]
        orderStr = 'order by '+option["sort_col"]+' '+option["sort_dir"]
      elsif option["is_topn"] == 1 && !option["top_n"].blank? && !option["topn_kpi"].blank?
        if option["sort_type"] ==1
          sortStr = ' asc'
        else
          sortStr = ' desc'
        end
        orderStr = 'order by '+option["topn_kpi"]+sortStr
      else
        if option["time_gran"] == 4
          orderStr = 'order by 日期,时段'+' '+option["sort_dir"]
        elsif option["time_gran"] == 3
          orderStr = 'order by 日期'+' '+option["sort_dir"]
        elsif option["time_gran"] == 2
          orderStr = 'order by 周'+' '+option["sort_dir"]
        elsif option["time_gran"] == 1
          orderStr = 'order by 月份'+' '+option["sort_dir"]
        elsif option["time_gran"] == 0
          orderStr = 'order by 季度'+' '+option["sort_dir"]
        else
          orderStr = ''
        end
      end
      sth_db.bind_param(14, orderStr)
      sth_db.bind_param(15, DBI::StatementHandle)#to bind ref cursor as DBI::StatementHandle
      sth_db.execute
      sth = sth_db.func(:bind_value, 15)
      @schema = sth.column_info
      @results = sth.fetch_all
      #      dbh.disconnect
    end
    result_set = Array.new
    schema_info = Array.new
    @schema.each do |s|
      schema_info << s["name"] unless s["name"].downcase == 'r'
    end
    length = @schema.length

    perf_types = Rms::PerfType.find(:all,:order=>'id')
    @results.each do |u|
      h = Hash.new
      i = 0
      for m in @schema
        value = u[i]
        key = m["name"]
        perf_types.each do |p|
          if key.eql?(p.name_cn)
            if p.is_percent == 1
              if !value
                value = ''
              end
              value = value * 100.0
              1.step(p.decimal_digits,1){|t| value = value * 10.0}
              value = value.to_f
              value = value.round
              1.step(p.decimal_digits,1){|t| value = value / 10.0}
              value = %r(#{value}%).source
            else
              if !value
                value = ''
              end
              1.step(p.decimal_digits,1){|t| value = value * 10.0}
              value = value.to_f
              value = value.round
              1.step(p.decimal_digits,1){|t| value = value / 10.0}
            end
            break
          end
        end
        if value.class.to_s.eql?('OraDate') #对时间的处理
          value = Time.parse(value.to_s).strftime("%Y-%m-%d")
        end
        h[key]= value
        if i == length - 1
          result_set << h
        end
        i += 1
      end
    end
    { :data => {:schema => schema_info, :result => result_set}}
  end
  
end
