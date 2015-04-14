class Report::RadiusStatReportsController < ApplicationController
  menu_item "report"
  sidebar "report"
  include Report::RadiusStatReportsHelper
  def index
    submenu_item params[:report_name]
    yesterday = Date.current - 1.days
    params[:time_gran] ||= "3"
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:area_gran] ||= (["1","6","7"].include?(params[:type].to_s) ? "0" : params[:type].to_s == "4" ? "1" : "8")
    params[:page] ||= 1
    if params[:format] == "csv"
      page = {:page_size => 100000, :page => 1}
    else
      page = {:page_size => 30, :page => params[:page]}
    end
    sort = parse_sort params[:sort]
    sort_name = sort[:name]
    sort.update({:name => sort_name[0,sort_name.index("(")]}) if sort_name && sort_name.include?("(") && ["1","2","3","4","5"].include?(params[:type].to_s)
    radius_stat = Procedure::WlanHnAuthPerfQry.new.query_radius(params[:type], params, sort, page)
    @radius_stat = WillPaginate::Collection.new(params[:page], 30, radius_stat.total_count)
    @grid = UI::Grid.new(radius_stat.column_info, radius_stat.results)
    respond_to do |format|
      format.html {}  #index.html
      format.csv{
        #全部导出
        @cols = radius_stat.column_info
        cols = []
        name_units = hn_radius_name_units
        @percent = []
        @cols.each_index { |i|
          col = @cols[i]
          if col.name == '日期'
            @row_num = i
          elsif col.name.include?("率") or col.name.end_with? "%"
            @percent << i
          end
          cols << col["name"] + (name_units[col["name"]].nil? ? "":"(#{name_units[col["name"]]})")
        }
        @results = radius_stat.results
        data = []
        data << cols.join(',')
        data  << "\r\n"
        @results.each do |record|
          if !@row_num.blank?
            record[@row_num] = record[@row_num].to_date
          end
          unless @percent.blank?
            @percent.each do |digits|
              record[digits] = "%.2f" %(record[digits].to_f * 100)
            end
          end
          record.pop
          data << record.join(',') << "\r\n"
        end
        @time = Time.now.strftime("%y-%m-%d-%H-%M-%S")
        send_data data.join.to_iso, :type => 'text/csv', :filename => "radius_stat_#{@time}.csv", :disposition => 'attachment'
      }
    end
  end

  def authfail_desc
    submenu_item params[:report_name]
    params[:sort] ||= 'id'
    if(["xml","csv","tsv"].include?(params[:format]))
      @error_codes = PortalErrorCode.all query
    else
      @error_codes = PortalErrorCode.paginate query(:page => params[:page])
    end
    @grid = UI::Grid.new(PortalErrorCode,@error_codes)
    
    respond_to do |format|
      format.html # authfail_desc.html.erb
    end
  end

  def query options = {}
    order_option options
    options.update({
        :select => "portal_error_codes.*"
      })
    options
  end
end
