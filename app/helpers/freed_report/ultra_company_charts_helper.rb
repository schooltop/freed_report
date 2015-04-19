 module FreedReport::UltraCompanyChartsHelper


   def freed_report_chart(kpi_style,widenum=710)
       #图表接口--ljf李江锋--2014-5-9
          @user_analyses=instance_variable_get("@#{kpi_style}")
          @column=instance_variable_get("@#{kpi_style}_column")
           if @user_analyses.nil?||@user_analyses.empty?
            concat "<div style=\"height:50%;font-family:\'宋体\';font-size:12px;padding:0 5px;padding-left:50%;position:relative;color:#184D97;\">
              <p>没有数据!</p></div>"
          else
            con_name="current_chart"
            str_xml = render("freed_report/ultra_company_charts/builder/user_data.builder")
            str_xml=CGI.unescapeHTML(str_xml)
            ult_render_chart '/FusionCharts/'+@column.chart_style_name,'',str_xml,con_name, widenum, 280, false, false do
            end
          end
   end

   def to_chart_hash(str)
     #图表属性转hash格式加载--2014-4-28--lij李江锋
     str.split(",").map{|a| a.split("=>")}.inject({}){|h,a| h[a[0].gsub(":",'')] = a[1].gsub('\'','');h}
   end

 end