class Report::StarbuckReportsController < ApplicationController

  menu_item "report"
  sidebar "report"

  def index
    submenu_item "starbuck_report"
    params[:area_dns] ||= areas.site_dn
    params[:areas] ||= areas.site_cn
    params[:netloc] ||= @current_user.cityid == 0 ? "1=1" : "cityid=#{@current_user.cityid}"
    params[:netloc_gran] ||= 4
    params[:time_gran] ||= 7
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
    starbuck_results = Procedure::WlanStarbuckQry.new.starbuck_analysis(params, page, sort, userid)
    params[:page] ||= 1
    @starbuck_results = WillPaginate::Collection.new(params[:page], 30, starbuck_results.total_count)
    @grid = UI::Grid.new(starbuck_results.column_info, starbuck_results.results)

    respond_to do |format|
      format.html {}  #index.html
      format.csv{
        #全部导出
        @cols = starbuck_results.column_info
        cols = []
        @cols.each_index { |i|
          col = @cols[i]
          cols << col["name"]
        }
        @results = starbuck_results.results
        data = []
        data << cols.join(',')
        data  << "\r\n"
        @results.each do |record|
          record.pop
          data << record.join(',')<< "\r\n"
        end
        @time = Time.now.strftime("%y-%m-%d-%H-%M-%S")
        send_data data.join.to_iso, :type => 'text/csv', :filename => "starbuck_analysis_#{@time}.csv", :disposition => 'attachment'
      }
    end
  end

  def areas
    bdn = @current_user.domain.base
    @current_user.cityid == 0 ? City.province : Area.find_by_site_dn("#{bdn}")
  end

end
