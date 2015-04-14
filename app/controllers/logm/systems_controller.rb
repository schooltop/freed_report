class Logm::SystemsController < ApplicationController

  sidebar "system"
  menu_item "system"

  def index
    submenu_item "system_log"
    clone_params = params.dup
    cond = Caboose::EZ::Condition.new :logm_systems do
        level =~ clone_params[:level] + '%' if clone_params[:level] and !clone_params[:level].empty?
        created_at > clone_params[:create_time] + '%' if clone_params[:create_time] and !clone_params[:create_time].empty?
      end
    if(["xml","csv","tsv"].include?(params[:format]))
      @system_log = Logm::SystemLog.find :all, :conditions =>cond.to_sql, :order => order_from_sort(params[:sort])
    else
      @system_log = Logm::SystemLog.paginate  :conditions =>cond.to_sql, :page => params[:page],:order => order_from_sort(params[:sort])
    end
    @grid = UI::Grid.new(Logm::SystemLog,@system_log)

    respond_to do |format|
      format.html 
      format.json { render :json =>@system_log}
      format.csv  {
        data  = @grid.to_csv
        send_data(data,:type=>'text/csv;header=persent',:filename => 'system_log.csv')
      }
    end
  end
end
