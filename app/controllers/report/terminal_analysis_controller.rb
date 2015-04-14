class Report::TerminalAnalysisController < ApplicationController
  sidebar 'report'
  menu_item "report"
  before_filter :query_prepared

  def index
    submenu_item "terminal_analysis"
    params[:time_range] ||= "yesterday"
    params[:area_gran] ||= 1
    params[:begin_time] ||= (Time.now - 1.day).strftime("%Y-%m-%d")
    params[:end_time] ||= (Time.now - 1.day).strftime("%Y-%m-%d")
    @cities = Site.find(:all,:conditions => "site_type = 1").collect{|c| [c.site_cn, "'#{c.site_cn}'"]}
    if params[:time_range] == '3' ||  params[:time_range] == "yesterday"
      @results = WlanTerminalUseDay.query_terminal(@page, @sort, params)
      column = WlanTerminalUseDay.export_columns
    elsif  params[:time_range] == '1' ||  params[:time_range] == "last_month"
      @results = WlanTerminalUseMonth.query_terminal(@page, @sort, params)
      column = WlanTerminalUseMonth.export_columns
    end
    @grid = UI::Grid.new(WlanTerminalUseDay, @results)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @results }
      format.csv {
        if params[:area_gran] == "0"
          column.delete("cityname")
        end
        data = @grid.to_csv(column)
        send_data(data, :type => 'text/csv; header=present', :filename => "terminal.csv")
      }
    end
  end

  private
  def query_prepared
    if params[:format] == 'csv'
      @page = {:page => 1, :per_page => 100000}
    else
      @page = {:page => params[:page], :per_page => 30}
    end
    @sort = parse_sort params[:sort]
  end

end
