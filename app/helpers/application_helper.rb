require "fusioncharts_helper"
include FusionchartsHelper
module ApplicationHelper

   def report_chart(action_title)
     render :partial=>"chack_con_link",:object=>"#{action_title}"
   end

   #图表接口--ljf李江锋--2014-5-9
   def freed_report_chart(kpi_style,area_gran,time_gran)
          @user_analyses=instance_variable_get("@#{area_gran}_#{time_gran}_#{kpi_style}")
          @column=instance_variable_get("@#{area_gran}_#{time_gran}_#{kpi_style}_column")
           if @user_analyses.nil?||@user_analyses.empty?
            concat "<div style=\"height:50%;font-family:\'宋体\';font-size:12px;padding:0 5px;padding-left:50%;position:relative;color:#184D97;\">
              <p>没有数据!</p></div>"
          else
            con_name="con_"+kpi_style+"_"+area_gran
            str_xml = render("first_pages/builder/user_data.builder")
            str_xml=CGI.unescapeHTML(str_xml) 
            render_chart '/FusionCharts/'+@column.chart_style_name,'',str_xml,con_name, 590, 280, false, false do
          end
          end
   end

   def to_chart_hash(str)
     #图表属性转hash格式加载
     str.split(",").map{|a| a.split("=>")}.inject({}){|h,a| h[a[0].gsub(":",'')] = a[1].gsub('\'','');h}
   end
   
   end
