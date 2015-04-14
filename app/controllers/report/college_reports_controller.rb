class Report::CollegeReportsController < ApplicationController

  menu_item "report"
  sidebar "report"

  def index
    submenu_item params[:report_name]
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    if params[:format] == "csv"
      page = {:page_size => 100000, :page => 1}
    else
      page = {:page_size => 30, :page => params[:page]}
    end
    sort = parse_sort params[:sort]
    userid = @current_user.id
    case params[:report_name]
    when "college_bytes"
      college_results = Procedure::CollegeBytesQry.new.query_college_bytes(params, userid, sort, page)
    when "college_top10"
      college_results = Procedure::CollegeTop10Qry.new.query_college_top10(params, userid, sort, page)
    when "college_detail"
      college_results = Procedure::CollegeDetailQry.new.query_college_detail(params, userid, sort, page)
    when "college_kpi"
      college_results = Procedure::CollegeKpiQry.new.query_college_kpi(params, userid, sort, page)
    when "bad_port"
      college_results = Procedure::CollegeBadportQry.new.query_college_bad_ports(params, userid, sort, page)
    else
      college_results = Procedure::CollegeBadcollegeQry.new.query_bad_college(params, userid, sort, page)
    end
    params[:page] ||= 1
    @college_results = WillPaginate::Collection.new(params[:page], 30, college_results.total_count)
    @grid = UI::Grid.new(college_results.column_info, college_results.results)

    respond_to do |format|
      format.html {}  #index.html
      format.csv{
        #全部导出
        @cols = college_results.column_info
        cols = []
        @cols.each_index { |i|
          col = @cols[i]
          cols << col["name"]
        }
        @results = college_results.results
        data = []
        data << cols.join(',')
        data  << "\r\n"
        @results.each do |record|
          record.pop
          data << record.join(',') << "\r\n"
        end
        @time = Time.now.strftime("%y-%m-%d-%H-%M-%S")
        send_data data.join.to_iso, :type => 'text/csv', :filename => "college_analysis_#{@time}.csv", :disposition => 'attachment'
      }
    end

  end

end
