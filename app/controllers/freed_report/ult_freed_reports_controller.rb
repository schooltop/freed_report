class  FreedReport::UltFreedReportsController < ApplicationController  #WLAN报表前置展示--李江锋--2013-10-22
  #menu_item "ultra"
  #sidebar "freed_report"
  include DbSql
  #layout "tool"

 def index
    session[:this_tab]="ult_freed_reports"
    sorts = parse_sort params[:sort]
    params[:sort]=sorts[:name]||nil
    params[:order]=sorts[:direction]||"desc"
    if(["xml","csv","tsv"].include?(params[:format]))
          params[:page]=nil
          find_ult_freed_reports(page=nil,{})
    else
          params[:page]=params[:page]||1
          find_ult_freed_reports(params[:page]||1,{})
    end
    @grid = UI::Grid.new(@columns, @page_ult_freed_reports)
   respond_to do |format|
      format.html
      format.json {render :json =>@ult_freed_reports}
      format.csv {
        columns = @columns
        datas = @grid.to_csv(columns) do |col,data|
            data[col]
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ult_freed_report'+params[:report_id].to_s+'_'+Time.now.to_s+'.csv')
      }
   end
 end

private
  def find_ult_freed_reports(page=nil,options={})
      excute_other_sql
      if page
         @ult_freed_reports=@ult_freed_reports.all.paginate(:page => page,:per_page => 30,:total_entries=>@count_sum_num) {}
      else
         @ult_freed_reports=@ult_freed_reports.all.paginate(:page => 1,:per_page => 6000) {}
      end
   end

end
