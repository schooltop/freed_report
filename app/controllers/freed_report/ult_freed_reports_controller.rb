class  FreedReport::UltFreedReportsController < ApplicationController  #WLAN报表前置展示--李江锋--2013-10-22
  menu_item "SQL报表"
  sidebar "ultra"
  include DbSql
  include Comment_Module

 def index
    sorts = parse_sort params[:sort]
    params[:sort]=sorts[:name]||nil
    params[:order]=sorts[:direction]||"desc"
    if(["xml","csv","tsv"].include?(params[:format]))
          params[:page]=nil
          find_ult_freed_reports(page=nil,{},params)
    else
          params[:page]=params[:page]||1
          find_ult_freed_reports(params[:page]||1,{},params)
    end
    @grid = UI::Grid.new(@columns, @page_ult_freed_reports)
   respond_to do |format|
      format.html
      format.json {render :json =>@ult_freed_reports}
      format.csv {
        columns = @columns-@hidden_columns-['RN']
        datas = @grid.to_csv(columns) do |col,data|
            case col
                    when '时间' then
                      if @current_model.time_gran&&@current_model.time_gran=="month"
                        data[col].to_s.to_date.strftime('%Y-%m')
                      elsif @current_model.time_gran&&@current_model.time_gran=="week"
                        data[col].to_s.to_date.strftime('%Y-%m %W')
                      elsif @current_model.time_gran&&@current_model.time_gran=="hour"
                        data[col].to_s.to_date.strftime('%Y-%m-%d %H')
                      else
                        data[col].to_s.to_date.strftime('%Y-%m-%d')
                      end
                    else
                       data[col]
                    end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ult_freed_report'+params[:report_id].to_s+'_'+Time.now.to_s+'.csv')
      }
   end
 end

private
  def find_ult_freed_reports(page=nil,options={},params=nil)
      excute_other_sql
      if page
         @ult_freed_reports=@ult_freed_reports.all.paginate(:page => page,:per_page => 30,:total_entries=>@count_sum_num) {}
      else
         @ult_freed_reports=@ult_freed_reports.all.paginate(:page => 1,:per_page => 6000) {}
      end
   end

end
