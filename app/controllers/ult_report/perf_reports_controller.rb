
require "time"
require "iconv"
require "spreadsheet/excel"

class UltReport::PerfReportsController < UltReport::ReportQueryController
  menu_item "ultra"
  include DbQuery
  sidebar "ultra"
  before_filter :setup_title
  def setup_title
    # @title = params[:controller]
  end

def index

         #通过编辑返回首页
      if     params[:report_con].nil?&&  !params[:netconName].nil?
              @netloc_granvalue= params[:netconName]
              params[:netconName] = @netloc_granvalue
      else
          if   params[:report_con].nil?
               params[:netconName] =0
               @netloc_granvalue=0
          else
              @netloc_granvalue=params[:report_con][:netloc_gran].to_s
              params[:netconName] = @netloc_granvalue
          end
       end
      unless params[:perf_template].blank? or params[:perf_template].empty? or params[:reporttype]!="3"
      params[:perf_template][:netloc] = "0" if params[:perf_template][:netloc].blank?
    end
    params[:id] = params[:id].to_i unless params[:id].nil?
    params[:reporttype] ||= 1
    params[:query_switch] ||= "regionConditions"
    params[:reporttype] = params[:reporttype].to_i
    params[:guid] ||= Time.now.to_i
     #puts "*************************************************************************************:"+params[:guid].to_s
    if params[:query_switch] == "portConditions"
      params[:netloc_cns] = params[:ports]
      params[:perf_template][:netloc] = search_port_ids(params[:ports])
    elsif !params[:netloc_cns].nil? && !params[:ports].blank?
      params[:netloc_cns] = params[:netloc_cns].gsub(params[:ports]+',',"")
    end

   #  puts        params[:perf_template][:netloc]

#    params[:netloc_cns] = params[:ports]
    case params[:reporttype]
    when 1: submenu_item "perf_report"
    when 3: submenu_item "case_report"
    when 2: submenu_item "alarm_report"
    when 4: submenu_item "resource_report"
    else submenu_item "perf_report"
    end
    @page_size = 30
     respond_to do |format|
        format.html {
           if @current_user.login == 'root'
              @report_templates = UltReport::ReportTemplate.find(:all,:conditions=>["report_type = #{params[:reporttype]} and group_type=3"])
           else
          @user_template_ids = UltReport::ReportTemplateUser.find(:all, :conditions => ["user_id = #{@current_user.id}"]).collect { |c| c.template_id }.join(",")
          if !@user_template_ids.nil? && @user_template_ids.length > 0
            @report_templates = UltReport::ReportTemplate.find(:all,:conditions=>["report_type = #{params[:reporttype] } and group_type=3 and id in (#{@user_template_ids})"])
          else
            @report_templates = []
          end
        end
        @perf_template = UltReport::ReportTemplate.new
        not_query = nil
       # puts "**********************************************************::::::"+params[:reporttype].to_s
        if(params[:reporttype] == 4)

          not_query = params[:id].nil? or (params[:datelist].nil?)
        else
          not_query = params[:id].nil? or params[:starTime].nil? or params[:endTime].nil?
        end



   unless not_query
         get_result_set
        #  puts "*************************************allcounts***********************************:"+@result_set[:total].to_s
          if(@result_set!=nil)
            @pages = WillPaginate::Collection.new(params[:page]||1,@page_size,@result_set[:total])
            @grid = UI::Grid.new(@result_set[:data][:schema],@result_set[:data][:result])
            #多个图的时候
            @chart_sets = @perf_template.chart_sets.collect{|chart| [chart.chart_name||"图片", chart.id] }
            params[:chart_seq] ||= @chart_sets.first[1] unless @chart_sets.empty?
            chart_set = UltReport::ChartSet.find(:first,:conditions=>{:template_id=>params[:id]})
            if chart_set #是否有图
            #  puts "*******************************************************************************"
              get_kpilist_data
              params[:kpi_name] ||= @kpilist_data.first.name_cn if @kpilist_data.size > 0
            end
          end
        end
      }
      format.csv{
        #全部导出
        params[:page] = 1
        @page_size = 1000000
        get_result_set
        start = Time.now
        csv_data = format_data_for_csv(:starTime => params[:starTime], :endTime => params[:endTime], :datelist => params[:datelist])
        p "Generate CSV: #{Time.now - start}s"
        data, time = csv_data[0], csv_data[1]
        send_data data, :type => 'text/csv', :filename => "report_#{time}.csv", :disposition => 'attachment'
      }
    end
  end



  def search_ports
    domain = "%#{@current_user.domain.base}"
    ports = DeviceInfo.find :all, :conditions => ["nodetype = 5 and nodedn like ? and nodecn like ?", domain, "%#{params[:q]}%"],
      :limit => params[:limit].to_i
    ports = ports.collect{|c| "#{c.nodecn}"}
    render :text => ports.join("\n"), :status => 200
  end

  def search_port_ids port_names
    if !port_names.blank?
      nodecns = port_names.gsub("，",",").strip.split(",").collect{|c| "(nodecn = '#{c}')"}.join(" or ")
      netloc = "(port in (select port from device_infos where (nodetype = 5) and (#{nodecns})))"
    else
      netloc = ""
    end
    netloc
  end

  def options_sub_type
    ids = params[:ids]
    if ids.include?("全部")
      @sub_type = Dic::Type.sub_site_type.dic_codes
    else
      ids = ids.delete_if{|x| x == "全部"}
      @sub_type = Dic::Code.find(:all, :conditions => {:parent_id => ids}) unless ids.nil?
    end
    respond_to do |format|
      format.ajax{
        render :layout => false
      }
    end
  end


  def options_ap_device_type
    id=params[:id]
    if id=="全部"
      @device_ap_kind=Dic::Type.ap_type.dic_codes
    else
      ap_device = Dic::Code.find(params[:id]) unless id.nil?
      code_label = ap_device.code_label
      ap_type = Dic::Type.find(:first,:conditions=>" type_name = 'ap_type' ")
      @device_ap_kind = Dic::Code.find(:all, :conditions=> " type_id = '#{ap_type.id}' and code_label like '%#{code_label}%' ")
    end
    respond_to do |format|
      format.ajax{
        render :layout => false
      }
    end
  end

  def options_sw_device_type
    id=params[:id]
    if id=="全部"
      @device_sw_kind=Dic::Type.sw_type.dic_codes
    else
      sw_device = Dic::Code.find(params[:id]) unless id.nil?
      code_label = sw_device.code_label
      sw_type = Dic::Type.find(:first,:conditions=>" type_name = 'sw_type' ")
      @device_sw_kind = Dic::Code.find(:all, :conditions=> " type_id = '#{sw_type.id}' and code_label like '%#{code_label}%' ")
    end
    respond_to do |format|
      format.ajax{
        render :layout => false
      }
    end
  end

   def convenient_report
   puts "*****************************************convenient_report_ultra******************************************************"
     @ssid_daily_reports =Ultra::ConvenientReport.ssid_daily_reports_top10 #ssid核查
     @businessdata_month_reports=Ultra::ConvenientReport.sx_monthly_reports_top12#WLAN业务运营报表
     @plan_month_reports=Ultra::ConvenientReport.sx_plan_monthly_reports_top13#计划部数据报表
     @apstate_daily_reports=Ultra::ConvenientReport.sx_apstate_daily_reports_top14#WLAN网管AP采集状态报表
     @access_month_reports =Ultra::ConvenientReport.query_wlan_monthly_report_top10 #WLAN接入成功率报表详情
     @count_ap_daily_reports =Ultra::ConvenientReport.count_ap_daily_report_top15 #山西统计采集AP
     @citylevle_apback_reports=Ultra::ConvenientReport.sx_citylevel_apback_reports_top16 #山西移动WLAN网管各地市分等级AP退服率一键式报表需求
     @apstate_count_reports=Ultra::ConvenientReport.sx_apstate_count_reports_top17#WLAN网管各地市AP采集状态报表
     @ap_offline_rate_reports = Ultra::ConvenientReport.sx_ap_offline_rate_daily_reports_top18 #山西移动WLANap离线率统计报表
     @busy_idle_bad_ap_reports = Ultra::ConvenientReport.sx_busy_idle_bad_ap_month_reports_top19 #山西移动WLAN超忙超闲最差ap月报
  submenu_item "alarm_match"
  end



  def convenient_report_month
   #puts "*****************************************convenient_report_ultra******************************************************"
    @quaitlysla_month_reports =Ultra::ConvenientReportMonth.quaitlysla_month_reports_top10 #湖北质量分析月报
    submenu_item "alarm_report"
  end

  def convenient_report_cq_clear_pro_marker#重庆AP剔除工程状态日报、月报、季报、小时报
    submenu_item "resource_report"
     puts "*****************************************convenient_report_cq_clear_pro_marker******************************************************"
     @cq_apdaily_reports = Ultra::ConvenientReport.cq_apdaily_reports_top1
     @cq_apmonthly_reports = Ultra::ConvenientReport.cq_apmonthly_reports_top2
     @cq_apquarter_reports = Ultra::ConvenientReport.cq_apquarter_reports_top3
     @cq_aphourly_reports=Ultra::ConvenientReport.cq_apquarter_reports_top4
  end

  def convenient_report_hn_ap#湖南-wlan网管-统计不同状态热点的AP不采集率和VIP热点AP的在线率需求
   puts "*****************************************convenient_report_ultra_hunan******************************************************"
    @hn_daily_reports =Ultra::ConvenientReport.hn_daily_reports_top10
    submenu_item "level_report"
  end

  def convenient_report_sx#陕西--减少资源明细
   puts "*****************************************convenient_report_ultra_sn******************************************************"
    @sx_daily_reports =Ultra::ConvenientReport.sn_daily_reports_top11
    submenu_item "convenient_report"
  end

  def all_reports
    puts "*****************************************convenient_report_all_reports******************************************************"
    params[:page] ||= 1
    @reports = Ultra::ConvenientReport.paginate(:all, :conditions=>["report_type=?", params[:report_type]], :order=>"created_at DESC", :page => params[:page])
    @grid = UI::Grid.new(Ultra::ConvenientReport, @reports)
    submenu_item "convenient_report"
  end

  def all_reports_month
    params[:page] ||= 1
    @reports = Ultra::ConvenientReportMonth.paginate(:all, :conditions=>["report_type=?", params[:report_type]], :order=>"created_at DESC", :page => params[:page])
    @grid = UI::Grid.new(Ultra::ConvenientReportMonth, @reports)
    submenu_item "convenient_report"
  end

  def target_description
    submenu_item "perf_report"
    @targets = Rms::WlanIndexDef.paginate(:all, :conditions => ["index_sys = 1"], :order => "id ASC", :per_page => 1000, :page => params[:page])
    @grid = UI::Grid.new(Rms::WlanIndexDef, @targets)
    render :layout => "iframe"
  end

  #取得统计结果的数据
  # filter_where  传入存储过程 查询的 过滤条件
  def get_result_set
    return if params[:id].nil? || params[:id] == 0
    if(params[:id] == -1)
      return if params[:perf_template].nil?
      @template_params = params[:perf_template].merge!({:userid => @current_user.id, :cityid => @current_user.cityid})
      @template_params.merge!(params[:report_con].except(:starTime, :endTime)) unless params[:report_con].nil?
      @template_params[:report_name] = "customize"
      @perf_template = UltReport::ReportTemplate.new_template(@template_params.except(:temp_user, :chart_sets, :report_template_users))
      @perf_template.id = params[:guid]
      # puts "****************************************cometimes*******************************"
     # puts  "***************************************guid************************************:"+params[:guid].to_s
      @perf_template.apply_dic_group_conditions(@template_params[:group_original])
      @perf_template.adjust_attributes
      params.delete(:query) and return if params[:query] == "skip"
    else
      @perf_template = UltReport::ReportTemplate.find_by_id(params[:id])
      if @perf_template.nil?
        @error_message = "你选择的模板不存在"
        render :template => "ult_report/common_reports/error" and return
      end
    end
    @perf_template.startdate = params[:starTime]
    @perf_template.enddate = params[:endTime]
    # list = params[:datelist]
    # if !list.nil? && list.is_a?(Array)
    #   list = list.delete_if { |x| x==''}
    #   list = list.uniq.join(',')
    # end
    # @datelist = list
    # @perf_template.datelist = list
    if (@perf_template.report_type ==1)||(@perf_template.report_type ==3) #性能模板/专案模板
      @missing_time = true and return if params[:starTime].nil? || params[:starTime].empty?
      @missing_time = true and return if params[:endTime].nil? || params[:endTime].empty?
      p @perf_template
      p "???????????????????????????????????????"
      p @perf_template.kpilist
     puts "************************************busytime*****************************:"+@perf_template.busytime.to_s+@perf_template.hourlist.nil?.to_s
     # if @perf_template.busytime == -3 && (@perf_template.hourlist.nil? || @perf_template.hourlist.empty?)
       # flash[:notice] = "统计时段不能为空"
       # redirect_to :action => 'index', :reporttype => @perf_template.report_type
      #else
        @result_set = perf_statistic(@perf_template)
     # end
    elsif (@perf_template.report_type ==2) #告警模板
      @missing_time = true and return if params[:starTime].nil? || params[:starTime].empty?
      @missing_time = true and return if params[:endTime].nil? || params[:endTime].empty?
      @result_set = alarm_statistic(@perf_template)
    else
      # @missing_time_list = true and return if list.nil? || list.empty?
      @missing_time = true and return if params[:starTime].nil? || params[:starTime].empty?
      @missing_time = true and return if params[:endTime].nil? || params[:endTime].empty?
      # if !@perf_template.device_class.empty? && !@perf_template.netloc.empty?
      #   @perf_template.netloc = "((#{@perf_template.netloc}) and (device_type='#{@perf_template.device_class}'))"
      # elsif @perf_template.netloc.empty? && !@perf_template.device_class.empty?
      #   @perf_template.netloc = "device_type='#{@perf_template.device_class}'"
      # end
      @result_set = config_statistic(@perf_template)
    end

  end

  #告警数据统计
  #POST
  def alarm_statistic(template)
    option = template.attributes
    option["localip"] = request.remote_ip

    sort = parse_sort params[:sort]
    option["sort_col"] = sort[:name]
    option["sort_dir"] = sort[:direction] || "ASC"
    option["page"] = params[:page]
    option["page"] ||= 0
    option["size"] = @page_size
    db_read_str = 'BEGIN WLAN_ALARM_QRY(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?); END;'
    stat_alarm_procedure(db_read_str,option)
  end


  private

  #执行存储过程=>告警统计存储过程
  #  /** 参数含义
  #       index_sys :指标体系  1：wlan  2：
  #       netloc_gran :查询粒度 0:省1:市2:郊县3:区局4:分局5:热点6:楼宇7:楼层8:AC
  #                   9:交换机10:交换机端口11:AP12:SSID
  #       netloc :数据筛选条件，例如：'((cityid=1)or(branch=2)or(device_type=5))'
  #       dic_group : 数据字典分组，例如：'device_type,device_manu,sender_class'...
  #                 sender_class:1 AC 2 SW 3 AP
  #       time_type : 时间类型，1：连续时间 2：间断时间
  #       startdate : time_type =1时需要填
  #       enddate : time_type =1时需要填
  #       date_list : time_type =2时需要填，例如：'2008-5-4,2008-5-6,2008-5-10'...
  #       time_gran :时间维查询方式：0=季，1=月，2=周，3=日，4=时，
  #                                  5=全时段 6=仅按小时聚合 7=所有时间聚合
  #                                  8=”仅按小时聚合并取最忙时指标“，则需要先按6统计
  #       cityid   :地市编号
  #       kpilist  :指标列表   1：告警数量  2：告警设备数量
  #       userid   :用户编号
  #       guid     :查询唯一标识
  #       localip  :本地IP地址
  #       p_order  :排序SQL，例如：' order by 日期,时段,热点,APID,无线侧接收字节数...'
  #       p_curPage   :当前页
  #       p_pageSize  :每页显示记录条数
  #       p_totalRecords  :总记录数
  #       p_totalPages    :总页数
  #       p_cursor1 :返回游标数据
  #  **/
  def stat_alarm_procedure(db_read_str, option = nil)
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
      sth_db.bind_param(10, option["cityid"])
      sth_db.bind_param(11, option["userid"])
      sth_db.bind_param(12, option["id"])
      sth_db.bind_param(13, option["localip"])
      if option["sort_col"]
        orderStr = 'order by '+option["sort_col"]+' '+option["sort_dir"]
      elsif option["is_topn"] == 1
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
      sth_db.bind_param(15, option["page"])
      sth_db.bind_param(16, option["size"])
      sth_db.bind_param(17, 9)
      sth_db.bind_param(18, 3)
      sth_db.bind_param(19, DBI::StatementHandle)#to bind ref cursor as DBI::StatementHandle
      sth_db.execute
      @total = sth_db.func(:bind_value, 17)
      sth = sth_db.func(:bind_value, 19)
      @schema = sth.column_info
      p "xcccccccccccccccccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
      p sth
      @results = sth.fetch_all
      #      dbh.disconnect
    end
    result_set = Array.new
    schema_info = Array.new
    @schema.each do |s|
      schema_info << s["name"] unless s["name"].downcase == 'r'
    end
    length = @schema.length

    dicGroup = option["dic_group"]
    if (not dicGroup.nil?)&&
        (dicGroup.upcase.include?('ALARM_TYPE')||
          dicGroup.upcase.include?('ALARM_ALIAS')||
          dicGroup.upcase.include?('SEVERITY_NAME'))
      perf_types = Rms::PerfType.find_by_sql("select 1 id,'告警数量' name_cn,0 decimal_digits,0 is_percent from dual
      union select 2 id,'告警设备数量' name_cn,0 decimal_digits,0 is_percent from dual
      union select 3 id,'告警修复数' name_cn,0 decimal_digits,0 is_percent from dual
      union select 4 id,'告警及时修复数' name_cn,0 decimal_digits,0 is_percent from dual
      union select 5 id,'及时修复率' name_cn,2 decimal_digits,1 is_percent from dual")
    else
      perf_types = Rms::PerfType.find_by_sql("select 1 id,'告警数量' name_cn,0 decimal_digits,0 is_percent from dual
      union select 2 id,'告警设备数量' name_cn,0 decimal_digits,0 is_percent from dual
      union select 3 id,'所有设备数量' name_cn,0 decimal_digits,0 is_percent from dual
      union select 4 id,'设备故障率' name_cn,2 decimal_digits,1 is_percent from dual
      union select 5 id,'告警修复数' name_cn,0 decimal_digits,0 is_percent from dual
      union select 6 id,'告警及时修复数' name_cn,0 decimal_digits,0 is_percent from dual
      union select 7 id,'及时修复率' name_cn,2 decimal_digits,1 is_percent from dual")
    end
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
    {:total => @total, :data => {:schema => schema_info, :result => result_set}}
  end
end
