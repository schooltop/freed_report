module FreedReport::UltFreedReportsHelper

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
       elsif (params[:report_id]&&(same.include? params[:report_id]))
         s="class='current'"
       else
         s=""
       end
       if same == sess
       img ="<img src='/stylesheets/themes/ultrapower/images2/menu_t_current.png' alt='#{old_tab_title}' border='0' align='absmiddle' style='margin-right:8px;margin-left:5px'>" if m == "site"
       "<li #{s}><a  href='/#{link}' title='#{old_tab_title}'>#{img}<font color='#ffffff'>#{tab_title}</font></a></li>"
       else
       img ="<img src='/stylesheets/themes/ultrapower/images2/menu_t.png' alt='#{old_tab_title}' border='0' align='absmiddle' style='margin-right:8px;margin-left:5px'>" if m == "site"
        "<li #{s}><a  href='/#{link}' title='#{old_tab_title}'>#{img}#{tab_title}</a></li>"
       end
   end
 
  def mark_unit(m,x) #报表搜索条件匹配  2013-12-17版 ---李江锋ljf
    if m[3]=="select"
    if m[4][0..3]=="sql="
        concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
        select( "#{m[0]}#{x}","",(@dbh.select_all "#{m[4][4..-1]}").collect {|p| [ p[0], p[1].to_s ]} ,{:include_blank => "全部",:selected =>params["#{m[0]}#{x}"]},:style => "width:262px;")
    else
        concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
        select( "#{m[0]}#{x}","",eval("#{m[4]}"),{:include_blank => "全部",:selected =>params["#{m[0]}#{x}"]},:style => "width:262px;")
    end
    elsif m[3]=="time"
        concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
       if  @current_model.time_gran=="hour"
         calendar_date_select_tag "#{m[0]}#{x}",params["#{m[0]}#{x}"]&&params["#{m[0]}#{x}"]!="" ? params["#{m[0]}#{x}"].to_time.strftime('%Y-%m-%d'): Time.now.yesterday.strftime('%Y-%m-%d'),:style => "width:240px;",:time => true
       else
         calendar_date_select_tag "#{m[0]}#{x}",params["#{m[0]}#{x}"]&&params["#{m[0]}#{x}"]!="" ? params["#{m[0]}#{x}"].to_time.strftime('%Y-%m-%d'): Time.now.yesterday.strftime('%Y-%m-%d'),:style => "width:240px;"
       end
   else
       concat label_tag "#{m[0]}","#{m[1]}：", :class=>'label',:style=>"width:90px;"
       text_field_tag "#{m[0]}#{x}",params["#{m[0]}#{x}"],:value=>params["#{m[0]}#{x}"],:style=>"width:257px;"
    end
  end

end
