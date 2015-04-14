module Report::RadiusReportsHelper
  def radius_netloc_gran
    concat label_tag :area_gran,"区域粒度：", :class=>'label'
    if ["2", "4"].include? params[:type].to_s
      select_tag :area_gran, options_for_select([["省", 0]], params[:area_gran].to_i)
    else
      select_tag :area_gran, options_for_select([["省", 0], ["市", 1], ["AC", 8]], params[:area_gran].to_i)
    end
  end

  def radius_time_gran(type=nil)
    concat label_tag :time_gran, "时间粒度：", :class => 'label'
    if type == 6
      select_tag :time_gran, options_for_select([["月",1],["周",2],["日",3]], params[:time_gran].to_i)
    else
      select_tag :time_gran, options_for_select([["年",-1],["季", 0],["月",1],["周",2],["日",3],["时",4]], params[:time_gran].to_i)
    end
    #"<select class=\"select ui-input\" id=\"time_gran\" name=\"time_gran\" original_value=\"3\"><option value=\"-1\">年</option>\n<option value=\"0\">季</option>\n<option value=\"1\">月</option>\n<option value=\"2\">周</option>\n<option value=\"3\" selected=\"selected\">日</option>\n<option value=\"4\">时</option></select>"
  end
  
  def column_widths(column_name)
    widths = {"省份" => 40, "地市" => 40, "日期" => 100, "AC厂家" => 100,
      "认证总次数" => 100, "AC_IP" =>  108,"年份" => 70, "季度" => 40, "月份" => 60, "周" => 40,
      "注册用户数" => 120, "活跃用户数" => 120
      }
    if widths.keys.include? column_name
      return widths[column_name]
    else
      return 190
    end
  end
end
