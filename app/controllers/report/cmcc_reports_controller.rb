class Report::CmccReportsController < Report::ReportQueryController   
  menu_item "report"
  submenu_item "cmcc_report"  
  before_filter :load_cmcc_types
   
  def index
    self.class.sidebar "report"
  end

  def show
    self.class.sidebar "report/cmcc_reports"    
    @page_size = (params[:format].nil? || params[:format] == "html") ? 30 : 100000
    @report_template = Rms::ReportTemplate.find_by_id params[:id]
    if @report_template.nil?
      @error_message = "你选择的模板不存在"
      render :template => "report/common_reports/error" and return
    end
    @chart_sets = @report_template.chart_sets.collect{|chart| [chart.chart_name||"图片", chart.id] }
    #传图的ID
    params[:chart_seq] ||= @chart_sets.first[1] unless @chart_sets.empty?

    #查找集团报表
    @busi_id = @report_template.crt_type.id #集团报表的类型
    value = @template_categories[@busi_id.to_i].value
    @relative_templates = Rms::ReportTemplate.find :all, :conditions => [value], :order => "report_name DESC"

    time_range = @report_template.get_time_range
    @report_template.startdate = params[:starTime] ? (params[:starTime].empty? ? time_range[0] : params[:starTime]) : time_range[0]
    @report_template.enddate = params[:endTime] ? (params[:endTime].empty? ? time_range[1] : params[:endTime]) : time_range[1]

    # @report_template.netloc = Rms::ReportTemplate.get_netloc(@current_user.domain.base)
    @report_template.build_netloc_for_common_and_cmcc(@current_user)
    if @report_template.report_type == 4
      if @report_template.netloc.empty?
        @report_template.netloc = "device_type='#{@report_template.device_class}'" if !@report_template.device_class.nil?
      else
        @report_template.netloc = "(#{@report_template.netloc}) and device_type='#{@report_template.device_class}'" 
      end
    end
    
    if @report_template.report_type == 1
      @result_set = perf_statistic(@report_template)
    else
      @result_set = config_statistic(@report_template)
    end

    if(@result_set!=nil)
      @pages = WillPaginate::Collection.new(params[:page]||1, @page_size, @result_set[:total])      
      @grid = UI::Grid.new(@result_set[:data][:schema],@result_set[:data][:result])

      chart_set = Rms::ChartSet.find(:first,:conditions=>{:template_id=>params[:id]})
      if chart_set #是否有图
        get_kpilist_data
        params[:kpi_name] ||= @kpilist_data.first.name_cn if @kpilist_data.size > 0
      end      
    end
    submenu_item @report_template.report_name
    respond_to do |format|
      format.html{}
      format.csv{
        #全部导出
        params[:page] = 1
        csv_data = format_data_for_csv(:starTime => @report_template.startdate.strftime("%y-%m-%d"), :endTime => @report_template.enddate.strftime("%y-%m-%d"))
        data, time = csv_data[0], csv_data[1]
        send_data data, :type => 'text/csv', :filename => "report_#{time}.csv", :disposition => 'attachment'
        # @schame = @result_set[:data][:schema]
        # @result = @result_set[:data][:result]
        # data = []
        # data << ["报表分析时间范围：","#{@report_template.startdate.strftime("%y-%m-%m")} " , "至 #{@report_template.enddate.strftime("%y-%m-%m")}\r\n"].join(",")
        # data << @schame.join(',') << "\r\n"
        # @result.each do |record|
        #   data << @schame.map {|key| record[key].to_s << "," } << "\r\n"
        # end
        # @time = Time.now.strftime("%y-%m-%d-%H:%M:%S")
        # send_data data.join.to_iso, :type => 'text/csv', :filename => "report_#{@time}.csv", :disposition => 'attachment'
      }
    end
  end

  private
  def load_cmcc_types 
    @template_categories = Rms::ReportTemplate.load_cmcc_report_template_types  
  end
end
