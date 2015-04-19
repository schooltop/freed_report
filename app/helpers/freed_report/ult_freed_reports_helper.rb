module FreedReport::UltFreedReportsHelper

  include Report_Chart
  include OtherMod
   
   SiteTabs.each do |m|    #报表导航类型定义   2013-12-17版 ---李江锋ljf
     define_method("#{m}_title_select") do |*arg|
       title,link,same = arg[0],arg[1],arg[2]||arg[0].to_s
       title_select title,link,same,session["#{m}_tab".to_sym],m
     end
   end

   def title_select(tab_title,link,same,sess,m)  #报表导航栏生成 2013-12-17版 ---李江锋ljf
       old_tab_title=tab_title
       tab_title=tab_title[0..27]+"..." if tab_title.length>27
       if (same == sess) 
         s="class='current'"
       elsif (params[:report_id]&&(same.include? "report_id=#{params[:report_id]}"))
         s="class='current'"
       elsif (params[:id]&&(same.include? "id=#{params[:id]}")&&(same.include? "ult_report/perf_reports"))
         s="class='current'"  
       else
         s=""
       end
       if same == sess || (params[:report_id]&&(same.include? "report_id=#{params[:report_id]}")) || (params[:id]&&(same.include? "id=#{params[:id]}")&&(same.include? "ult_report/perf_reports"))
       img ="<img src='/stylesheets/themes/ultrapower/images2/menu_t_current.png' alt='#{old_tab_title}' border='0' align='absmiddle' style='margin-right:8px;margin-left:5px'>" if m == "sys"
       "<li #{s}><a  href='/#{link}' title='#{old_tab_title}'>#{img}<font color='#ffffff'>#{tab_title}</font></a></li>"
       else
       img ="<img src='/stylesheets/themes/ultrapower/images2/menu_t.png' alt='#{old_tab_title}' border='0' align='absmiddle' style='margin-right:8px;margin-left:5px'>" if m == "sys"
        "<li #{s}><a  href='/#{link}' title='#{old_tab_title}'>#{img}#{tab_title}</a></li>"
       end
   end
 
  def mark_unit(m,x) #报表搜索条件匹配  2013-12-17版 ---李江锋ljf
    if m[3]=="select"
    if m[4][0..3]=="sql="
        concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
        select( "#{m[0]}#{x}","",(@dbh.select_all "#{m[4][4..-1]}").collect {|p| [ p[0], p[1].to_s ]} ,{:include_blank => "全部",:selected =>params["#{m[0]}#{x}"]},:style => "width:262px;")
    else
        catch_source=[]
        m[4].split(',').each{|m| catch_source<<[m.split('|')[0].to_s,m.split('|')[1].to_s]}
        concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
        select( "#{m[0]}#{x}","",catch_source,{:include_blank => "全部",:selected =>params["#{m[0]}#{x}"]},:style => "width:262px;")
    end
    elsif m[3]=="time"
      if params["T.DAYTIME#{x}"]
         params["#{m[0]}#{x}"]=params["T.DAYTIME#{x}"]
      elsif params["T.WEEKTIME#{x}"]
         params["#{m[0]}#{x}"]=params["T.WEEKTIME#{x}"]
      elsif params["T.MONTHTIME#{x}"]
         params["#{m[0]}#{x}"]=params["T.MONTHTIME#{x}"]
      end
        concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
       if  @current_model.time_gran=="hour"
        text_field_tag "#{m[0]}#{x}",params["#{m[0]}#{x}"]&&params["#{m[0]}#{x}"]!="" ? params["#{m[0]}#{x}"].to_time.strftime('%Y-%m-%d 00:00'): Time.now.yesterday.strftime('%Y-%m-%d 00:00'),:class =>"input_01",:id =>"date_time#{x}",:style => "width:256px;",:onclick=>"check_date(#{x},1)",:onmouseover=>"check_date(#{x},1)"
      else
        text_field_tag "#{m[0]}#{x}",params["#{m[0]}#{x}"]&&params["#{m[0]}#{x}"]!="" ? params["#{m[0]}#{x}"].to_time.strftime('%Y-%m-%d'): Time.now.yesterday.strftime('%Y-%m-%d'),:class =>"input_01",:id =>"date_time#{x}",:style => "width:256px;",:onclick=>"check_date(#{x},0)",:onmouseover=>"check_date(#{x},0)"
       end
    else
       concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
       text_field_tag "#{m[0]}#{x}",params["#{m[0]}#{x}"],:value=>params["#{m[0]}#{x}"],:style=>"width:257px;"
    end
  end

  def current_page_report_chart(kpi_style,widenum=1116)
       #图表接口--ljf李江锋--2014-5-9
          send("#{kpi_style}")
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

end

