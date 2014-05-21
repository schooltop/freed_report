class FirstPagesController < ApplicationController
include Comment_Module

def index
  this_tab
  time_gran=params[:time_gran]?"#{params[:time_gran]}":"day"
  begin_time=params[:begin_time]?params[:begin_time]:time_gran=="month"?"2014-5":"2014-3-25"
  @begin_time= params[:begin_time]=begin_time
  params[:time_gran]=time_gran
  first_page_views
end


def area_gran_check
  @area_gran=params[:area_gran]
  @kpi_style=params[:kpi_style]
  @time_gran=params[:time_gran]
  combin_name(@kpi_style,@time_gran,@area_gran)
  page_db_connects
  send(@find_combin_name)
  @dbh.disconnect if @dbh
  render :partial=>"freed_report_chart_partial"
end

def combin_name(kpi_style,time_gran,area_gran)
  @find_combin_name="#{area_gran}_#{time_gran}_#{kpi_style}"
end

end
