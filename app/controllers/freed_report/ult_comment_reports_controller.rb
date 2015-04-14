class  FreedReport::UltCommentReportsController < ApplicationController  #WLAN公用报表模块--李江锋ljf--2014-3-5
   menu_item "ultra"
  sidebar "ultra"
  include DbSql
  #layout false
 def index
    sorts = parse_sort params[:sort]
    params[:sort]=sorts[:name]||nil
    params[:order]=sorts[:direction]||"desc"
    if(["xml","csv","tsv"].include?(params[:format]))
        find_ult_freed_reports(page=nil,{},params)
        @grid = UI::Grid.new(@columns, @ult_freed_reports)
          respond_to do |format|
              format.html
              format.json {render :json =>@ult_freed_reports}
              format.csv {
                columns = @columns
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
                send_data(datas,:type=>'text/csv;header=persent',:filename => 'ult_comment_report'+params[:report_id].to_s+'_'+Time.now.to_s+'.csv')
              }
          end
    else
          find_ult_freed_reports(params[:page]||1,{},params)
          @grid = UI::Grid.new(@columns, @page_ult_freed_reports)
          render :action=>"index"
    end
 end



def method_missing(method_name, *args)
  @report_source=FreedReport::UltReportModel.find(:first,:conditions=>"show_title='#{method_name}'")
  if  @report_source
      submenu_item "#{@report_source.model_style}"
      params[:report_id]=@report_source.id
      index
  else
      super
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
