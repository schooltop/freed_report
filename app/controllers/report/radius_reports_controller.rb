class Report::RadiusReportsController < ApplicationController
  menu_item "report"
  sidebar "report"
  def index
    submenu_item params[:report_name]
    yesterday = Date.current - 1.days
    params[:time_gran] ||= "3"
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:area_gran] ||= ["2", "4"].include?(params[:type].to_s) ? "0" : "8"
    params[:page] ||= 1
    if params[:format] == "csv"
      page = {:page_size => 100000, :page => 1}
    else
      page = {:page_size => 30, :page => params[:page]}
    end
    sort = parse_sort params[:sort]
    if params[:type].to_i == 6
      sort_name = sort[:name]
      sort = sort.update({:name => sort_name[0,sort_name.index("(")]}) if sort_name && sort_name.include?("(")
      radius = Procedure::AuthUserStatQry.new.query_user_stat(params, sort, page)
    else
      radius = Procedure::RadiusQry.new.query_radius(params[:type], params, sort, page)
    end
    @radius = WillPaginate::Collection.new(params[:page], 30, radius.total_count)
    @grid = UI::Grid.new(radius.column_info, radius.results)
    respond_to do |format|
      format.html {}  #index.html
      format.csv{
        #全部导出
        @cols = radius.column_info
        cols = []
        name_units = Rms::PerfType.index_units
        if params[:type].to_i == 6
          name_units = Rms::PerfType.index_units.update({
              "注册用户数" => "个","活跃用户数" => "个","用户使用时长" => "时",
              "上行业务流量" => "GB", "下行业务流量" => "GB","用户业务流量总和" => "GB"})
        end
        @decimal_digits = []
        @cols.each_index { |i|
          col = @cols[i]
          if col.name == '日期'
            @row_num = i
          elsif ["用户使用时长","上行业务流量", "下行业务流量","用户业务流量总和"].include?(col.name)
            @decimal_digits << i
          end
          cols << col["name"] + (name_units[col["name"]].nil? ? "":"(#{name_units[col["name"]]})")
        }
        @results = radius.results
        data = []
        data << cols.join(',')
        data  << "\r\n"
        @results.each do |record|
          if !@row_num.blank?
            record[@row_num] = record[@row_num].to_date
          end
          unless @decimal_digits.blank?
            @decimal_digits.each do |digits|
              record[digits] = "%.2f" %(record[digits])
            end
          end
          record.pop
          data << record.join(',') << "\r\n"
        end
        @time = Time.now.strftime("%y-%m-%d-%H-%M-%S")
        # ic = Iconv.new('GB2312//IGNORE', 'UTF-8//IGNORE')
        # send_data ic.iconv(data.join), :type => 'text/csv', :filename => "analysis_#{@time}.csv", :disposition => 'attachment'      
        send_data data.join.to_iso, :type => 'text/csv', :filename => "analysis_#{@time}.csv", :disposition => 'attachment'      
      }
    end
  end
end
