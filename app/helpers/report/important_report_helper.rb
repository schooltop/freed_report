module Report::ImportantReportHelper
  def rms_begin_time
    concat label_tag :begin_time,"时间：开始时间 &nbsp", :class=>'left', :style => "margin-top:5px;"
    text_field_tag :begin_time,params[:begin_time],:id=>'begin_time', :style => "width:80px;",:original_value => params[:begin_time]
  end

   def rms_end_time
    concat label_tag :end_time, "&nbsp&nbsp&nbsp结束时间 &nbsp", :class=>'label'
    text_field_tag :end_time,params[:end_time],:id=>'end_time', :style => "width:80px;",:original_value => params[:end_time]
  end

  def ultra_time_range
    concat label_tag :time_range, "时间范围：" ,:class=>' label'
    select_tag :time_range,options_for_select([ ['自定义（月）', "1"]],
      params[:time_range]),:class=>'time_range'
  end
end
