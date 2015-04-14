class Report::AlarmStandardReportsController < ApplicationController
  sidebar 'report'
  menu_item "report"

  def index
    submenu_item params[:report_name]
    params[:time_gran] ||= "3"
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    if params[:format] == "csv"
      page = {:page_size => 100000, :page => 1}
    else
      page = {:page_size => 30, :page => params[:page]}
    end
    sort = parse_sort params[:sort]
    
    alarm_standard = Procedure::WlanAlarmStandardQry.new.alarm_standard_analysis(params, sort, page)
    params[:page] ||= 1
    @alarm_standard = WillPaginate::Collection.new(params[:page], 30, alarm_standard.total_count)
    @grid = UI::Grid.new(alarm_standard.column_info, alarm_standard.results)

    respond_to do |format|
      format.html {}  #index.html
      format.csv{
        #全部导出
        @cols = alarm_standard.column_info
        cols = []
        @decimal_digits = []
        @cols.each_index { |i|
          col = @cols[i]
          if col.name == '日期'
            @row_num = i
          elsif ["验证率(%)","匹配率(%)"].include?(col.name)
            @decimal_digits << i
          end
          cols << col["name"]
        }
        @results = alarm_standard.results
        data = []
        data << cols.join(',')
        data  << "\r\n"
        @results.each do |record|
          if !@row_num.blank?
            record[@row_num] = record[@row_num].to_date
          end
          unless @decimal_digits.blank?
            @decimal_digits.each do |digits|
              record[digits] = "%.2f" %(record[digits]*100)
            end
          end
          record.pop
          data << record.join(',') << "\r\n"
        end
        @time = Time.now.strftime("%y-%m-%d-%H-%M-%S")
        send_data data.join.to_iso, :type => 'text/csv', :filename => "alarm_standard_report_#{@time}.csv", :disposition => 'attachment'
      }
    end
  end

end
