class Logm::OperationsController < ApplicationController
  
  sidebar "system"
  menu_item "system"
  include Logm::OperationsHelper
  def index
    submenu_item "operation_log"
    params[:sort] ||= '-created_at'
    if(["xml","csv","tsv"].include?(params[:format]))
      @operation_log = Logm::OperationLog.all query
    else
      @operation_log = Logm::OperationLog.paginate query(:page => params[:page])
    end
    @grid = UI::Grid.new(Logm::OperationLog, @operation_log)
    respond_to do |format|
      format.html #index.html.erb
      format.json { render :json =>@operation_log}
      format.csv{
        columns = Logm::OperationLog.export_column_names
        m = {}
        modules.each do |mod|
          m[mod[1]] = mod[0]
        end
        action = {}
        actions.each do |act|
          action[act[1]] = act[0]
        end
        datas = @grid.to_csv(columns) do |col,data|
          case col
          when 'module_name' then t data[col]
          when 'action' then t data[col]
          else
            data[col]
          end
        end
        send_data(datas, :type => 'text/csv; header=present', :filename => 'operation_log.csv')
      }
    end
  end

  private
  def query options={}
    order_option options
    operation = params[:operation]
    unless operation.blank?
      username = operation[:user_name]
      start_time = operation[:start_time]
      end_time = operation[:end_time]
      modules = operation[:module_name]
      actions = operation[:action]
      results = operation[:result]
    end
    cond = Caboose::EZ::Condition.new :logm_operations do
      user_name =~ "%#{username}%" unless username.blank?
      created_at >= start_time unless start_time.blank?
      module_name == modules unless modules.blank?
      action == actions unless actions.blank?
      result == results unless results.blank?
    end
    cond << "to_days(updated_at) <= to_days('#{end_time}')" unless end_time.blank?
    options.update({
        :select => "logm_operations.*",
        :conditions => cond.to_sql
      })
    options
  end
end
