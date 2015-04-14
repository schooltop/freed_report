module Report::RadiusStatReportsHelper
  def hn_radius_netloc_gran
    concat label_tag :area_gran,"区域粒度：", :class=>'label'
    if ["1","6","7"].include?(params[:type].to_s)
      select_tag :area_gran, options_for_select([["省", 0]], params[:area_gran].to_i)
    elsif params[:type].to_s == "4"
      select_tag :area_gran, options_for_select([["省", 0], ["市", 1]], params[:area_gran].to_i)
    else
      select_tag :area_gran, options_for_select([["省", 0], ["市", 1], ["AC", 8]], params[:area_gran].to_i)
    end
  end

  def hn_radius_time_gran(type=nil)
    concat label_tag :time_gran, "时间粒度：", :class => 'label'
    if ["1","4","5"].include? type.to_s
      select_tag :time_gran, options_for_select([["年",-1],["季", 0],["月",1],["周",2],["日",3]], params[:time_gran].to_i)
    else
      select_tag :time_gran, options_for_select([["年",-1],["季", 0],["月",1],["周",2],["日",3],["时",4]], params[:time_gran].to_i)
    end
  end
  
  def hn_column_widths(column_name)
    widths = {"省份" => 40, "地市" => 40, "日期" => 80, "AC_IP" =>  115,
      "年份" => 70, "季度" => 40, "月份" => 60, "周" => 40,
      "RADIUS认证请求数" => 135,"RADIUS认证成功数" => 135
      
    }
    if widths.keys.include? column_name
      return widths[column_name]
    else
      return 170
    end
  end

  def hn_radius_name_units
    Rms::PerfType.index_units.update({
        "WLAN注册用户数" => "个","WLAN新开用户数" => "个","WLAN活跃用户数" => "个","WLAN用户上网总时长" => "分",
        "WLAN用户上网总流量" => "MB","WLAN用户上网平均时长" => "分","WLAN用户上网平均流量" => "MB",
        "校园用户上线请求数" => "个","校园用户上线成功数" => "个","校园用户上线成功率" => "%",
        "校园用户下线请求数" => "个","校园用户下线成功数" => "个","校园用户下线成功率" => "%",
        "WLAN校园网注册用户数" => "个","WLAN校园网活跃用户数" => "个","WLAN校园网用户使用时长" => "分",
        "WLAN校园网用户业务流量" => "MB"})
  end

  def radius_error_codes(column_name)
    codes = PortalErrorCode.find(:all).collect {|c| c.error_code}
    codes.include?(column_name)
  end
end
