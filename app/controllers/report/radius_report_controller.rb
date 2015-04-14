class Report::RadiusReportController < ApplicationController
  menu_item "report"
  sidebar "report"
  submenu_item "radius_report"
  
  def index
    params[:start_date] ||= "2010-12-01"
    params[:end_date] ||= "2010-12-31"
    params[:area_gran] ||= "city"
    params[:time_gran] ||= 2
    sort = parse_sort params[:sort]    
    @radius = Rms::RadiusPortal.query_by_user(params, sort, params[:page] || 1)
    @grid = UI::Grid.new(Rms::RadiusPortal, @radius)
  end
end