class Logm::SecuritiesController < ApplicationController
  sidebar "system"
  menu_item "system"
  
  def index
    submenu_item "securities"
    params[:sort] ||="-created_at"
    if(["xml","csv","tsv"].include?(params[:format]))
      @security_log = Logm::SecurityLog.all query
    else
      @security_log = Logm::SecurityLog.paginate query(:page => params[:page])
    end
    @grid = UI::Grid.new(Logm::SecurityLog, @security_log)
    respond_to do |format|
      format.html #index.html.erb
      format.json { render :json =>@security_log}
      format.csv {
        columns = Logm::SecurityLog.export_column_names
        action = {"sessions/create" => "登陆系统","sessions/logout" => "退出系统"}
        datas = @grid.to_csv(columns) do |col,data|
          case col
          when 'security_action' then action[data[col]]
          else
          data[col]
          end
        end
        send_data(datas,:type => 'text/csv;header=present', :filename => 'security_log.csv')
      }
    end
  end

  private
  def query options={}
    order_option options
    security = params[:security]
    unless security.blank?
      username = security[:user_name]
      start_time = security[:start_time]
      end_time = security[:end_time]
    end
    cond = Caboose::EZ::Condition.new :logm_securities do
      user_name =~ "%#{username}%" unless username.blank?
      created_at >= start_time unless start_time.blank?
    end
    cond << "to_days(updated_at) <= to_days('#{end_time}')" unless end_time.blank?
    options.update({
        :select => "
        logm_securities.*",
        :conditions => cond.to_sql
      })
    options
  end
end
