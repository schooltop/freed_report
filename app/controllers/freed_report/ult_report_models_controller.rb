class  FreedReport::UltReportModelsController < ApplicationController   #前置报表模版配置功能--2013-12-31版--李江锋ljf
  menu_item "SQL报表"
  sidebar "ultra"
  include DbSql

  def index
    #session[:sys_tab]="配置"
    #session[:site_tab]="freed_reportult_report_models"
    submenu_item "common_report"
    str=""
    if params[:name]&&params[:name]!=""
      str+=" and name like '%#{params[:name]}%'"
    end
    if params[:created_at]&&"#{params[:created_at]}"!=""
      str+=" and created_at>=to_date('#{params[:created_at]}','YYYY-MM-DD')"
    end
    if params[:time_gran]&&"#{params[:time_gran]}"!=""
      str+=" and area_gran = '#{params[:time_gran]}'"
    end
    if params[:area_gran]&&"#{params[:area_gran]}"!=""
      str+=" and area_gran = '#{params[:area_gran]}'"
    end
    @ult_report_models = FreedReport::UltReportModel.find_by_sql("select * from ult_report_models where top_style<>1 #{str} order by id desc ").paginate(:page => params[:page],:per_page => 30)
    @grid = UI::Grid.new(FreedReport::UltReportModel, @ult_report_models)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ult_report_models }
    end
  end

  def call_url
    #2014-7-29检索数据源格式化
    render :layout=>false
  end

  def check_model_text
    #模版模糊查询
    @model_text_search=CGI::unescape(params[:text_input])
    @ult_report_models=FreedReport::UltReportModel.find(:all,:conditions=>"name like '%#{@model_text_search}%' ",:order=>"name desc,area_gran,time_gran")
    render :partial => 'model_text'
  end

  def copy_report_model
    #复制模版--2014-6-26--ljf李江锋
    @ult_report_model = FreedReport::UltReportModel.find(params[:id].to_i)
    param={}
    param[:ult_report_model]={}
    param[:ult_report_model][:ultra_company_db_model_id]=@ult_report_model.ultra_company_db_model_id
    param[:ult_report_model][:report_link]=@ult_report_model.report_link
    param[:ult_report_model][:show_title]=@ult_report_model.show_title
    param[:ult_report_model][:name]=@ult_report_model.name
    param[:ult_report_model][:time_gran]=@ult_report_model.time_gran
    param[:ult_report_model][:area_gran]=@ult_report_model.area_gran
    param[:ult_report_model][:str_sql]=@ult_report_model.str_sql
    param[:db_name]=@ult_report_model.ultra_company_db_model.db_name
    param[:db_user]=@ult_report_model.ultra_company_db_model.db_user
    param[:db_style]=@ult_report_model.ultra_company_db_model.db_style
    param[:db_password]=@ult_report_model.ultra_company_db_model.db_password
    param[:db_port]=@ult_report_model.ultra_company_db_model.db_port
    param[:db_host]=@ult_report_model.ultra_company_db_model.db_host
    param[:db_service]=@ult_report_model.ultra_company_db_model.db_service
    param[:menu]=@ult_report_model.ultra_company_tabmenu.id if @ult_report_model.ultra_company_tabmenu
    param[:copy_model_id]=params[:id]
    flash[:notice] = "以下是复制的模版内容，请检查并作相关改进。"
    redirect_to :action => 'new',:param=>param
  end
  
  def new
    submenu_item "common_report"
    if params[:param]
      #接收复制模版参数
      params[:ult_report_model]=params[:param][:ult_report_model]
      params[:db_name]=params[:param][:db_name]
      params[:db_user]=params[:param][:db_user]
      params[:db_style]=params[:param][:db_style]
      params[:db_password]=params[:param][:db_password]
      params[:db_port]=params[:param][:db_port]
      params[:db_host]=params[:param][:db_host]
      params[:db_service]=params[:param][:db_service]
      params[:menu]=params[:param][:menu]
      params[:copy_model_id]=["#{params[:param][:copy_model_id]}"]
    end  
    @ult_report_model = FreedReport::UltReportModel.new
    @from_report_model = FreedReport::UltReportModel.find(params[:from_report_model_id].to_i) if params[:from_report_model_id]
    respond_to do |format|
      format.html #new.html.erb
      format.xml {render :xml => @ult_report_model}
    end
  end

   def create
     if params[:ult_report_model]
       if params[:ult_report_model][:str_sql].to_s.include?"delete"
          flash[:notice] ="报表模版创建失败，sql脚本中包含非法字符delete！"
          redirect_to :action => 'new',:param=>params
       else
            @un_conn_message=""          
            begin
              db_connects("#{params[:db_style]}",config_db_con(params["db_host"],params["db_port"],params["db_service"],"#{params[:db_style]}"),params["db_user"],params["db_password"])
            rescue
              @un_conn_message += "报表数据源配置有问题，请测试；"
            end
            begin
              @cullent_attributes=@dbh.execute("#{content_message(params[:ult_report_model][:str_sql])}")
              #@columns=@cullent_attributes.column_names
              create_report
              flash[:notice] ="报表模版创建成功。如需搜索选项，请完善检索配置，或点击<a href='/freed_report/ult_freed_reports?report_id=#{@ult_report_model.id}'>[查看报表]</a>前往查看报表结果。"
              redirect_to :action => 'mark_targs' ,:id=>@ult_report_model.id
            rescue
              @un_conn_message +="请编写sql脚本；"  if params[:ult_report_model][:str_sql].to_s.include?"填写sql脚本注意事项"
              flash[:notice] = @un_conn_message+"报表模版sql语句有问题，请测试。"
              redirect_to :action => 'new',:param=>params
            end
            @dbh.disconnect if @dbh
       end
     end
   end

  def create_report
            @modelmenu=FreedReport::Tabmenu.find_by_name("SQL报表")
            @ult_report_model = FreedReport::UltReportModel.new(params[:ult_report_model])
            @ult_report_model.user_id=current_user.id
            @ult_report_model.top_style=0
            #@ult_report_model.show_title=@columns.join(',')
            @ult_report_model.systype="SQL报表"
            @ult_report_model.ultra_company_db_model_id=""
            @ult_report_model.save
            #add_from_report_title if params[:ult_report_model][:parent_id]
            check_db_model
            @ult_report_model.ultra_company_db_model_id=@db_model.id
            @ult_report_model.save
            @tabmenu=FreedReport::Tabmenu.new
            @tabmenu.name=@ult_report_model.name
            @tabmenu.modelname="SQL报表"
            @tabmenu.top_style=0
            @tabmenu.top_style=1 if params[:ult_report_model][:parent_id]
            @tabmenu.url="freed_report/ult_freed_reports?report_id=#{@ult_report_model.id}"
            @tabmenu.parent_id="#{params[:menu]}"#||@modelmenu ? @modelmenu.id : ""
            @tabmenu.user_id=current_user.id
            @tabmenu.ult_report_model_id=@ult_report_model.id
            @tabmenu.save
   end

  def add_from_report_title
    #处理父表钻取连接
    params[:from_report_link][:report_link]
    #处理父表隐藏列
    params[:from_report_link][:hidden_link]
  end

  def check_db_model #配置数据模型数据源
     @db_model=FreedReport::UltraCompanyDbModel.find(:last,:conditions=>"db_name='#{params[:db_name]}'")
     @db_model=FreedReport::UltraCompanyDbModel.new unless @db_model
     @db_model.db_style="#{params[:db_style]}"
     @db_model.db_name=params["db_name"]
     @db_model.db_user=params["db_user"]
     @db_model.db_password=params["db_password"]
     @db_model.db_port=params["db_port"]
     @db_model.db_host=params["db_host"]
     @db_model.db_service=params["db_service"]
     @db_model.db_con=config_db_con(params["db_host"],params["db_port"],params["db_service"],"#{params[:db_style]}")
     @db_model.user_id=current_user.id
     @db_model.save
  end

  def config_db_con(db_host=nil,db_port=nil,db_service=nil,db_style=nil)  #配置数据连接
     if db_style=="oracle"
     @db_con="(DESCRIPTION =(ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST = #{db_host})(PORT = #{db_port})))(CONNECT_DATA =(SERVICE_NAME = #{db_service})(SERVER = DEDICATED)))"
     elsif db_style=="mysql"
     @db_con="#{db_service}:#{db_host}"
     end
     return @db_con
  end

  def edit
    submenu_item "common_report"
    @ult_report_model = FreedReport::UltReportModel.find(params[:id])
    if @ult_report_model.ultra_company_db_model
      @ultra_company_db_model=@ult_report_model.ultra_company_db_model
      params[:ultra_company_db_model_id]=@ult_report_model.ultra_company_db_model_id
      params[:db_name]=@ultra_company_db_model.db_name
      params[:db_user]=@ultra_company_db_model.db_user
      params[:db_style]=@ultra_company_db_model.db_style
      params[:db_password]=@ultra_company_db_model.db_password
      params[:db_port]=@ultra_company_db_model.db_port
      params[:db_host]=@ultra_company_db_model.db_host
      params[:db_service]=@ultra_company_db_model.db_service
      if @ult_report_model.ultra_company_tabmenu
        params[:menu]=@ult_report_model.ultra_company_tabmenu.id
      end
    end

    if params[:param]
        params[:ult_report_model]=params[:param][:ult_report_model]
        params[:db_name]=params[:param][:db_name]
        params[:db_user]=params[:param][:db_user]
        params[:db_style]=params[:param][:db_style]
        params[:db_password]=params[:param][:db_password]
        params[:db_port]=params[:param][:db_port]
        params[:db_host]=params[:param][:db_host]
        params[:db_service]=params[:param][:db_service]
        params[:menu]=params[:param][:menu]
    end

    respond_to do |format|
      format.html #edit.html.erb
      format.xml {render :xml => @ult_report_model}
    end
  end

   def show
    @ult_report_model = FreedReport::UltReportModel.find(params[:id])
    respond_to do |format|
      format.html #edit.html.erb
      format.xml {render :xml => @ult_report_model}
    end
  end

  def update
     if params[:ult_report_model]
       @ult_report_model = FreedReport::UltReportModel.find(params[:id])
         if params[:ult_report_model][:str_sql].to_s.include?"delete"
             flash[:notice] ="报表模版创建失败，sql脚本中包含非法字符delete！"
             redirect_to :action => 'edit',:param=>params,:id=>params[:id]
         else
            @un_conn_message=""
            begin
              db_connects("#{params[:db_style]}",config_db_con(params["db_host"],params["db_port"],params["db_service"],"#{params[:db_style]}"),params["db_user"],params["db_password"])
            rescue
              @un_conn_message += "报表数据源配置有问题，请测试；"
            end
            begin
              @cullent_attributes=@dbh.execute("#{content_message(params[:ult_report_model][:str_sql])}")
              #@columns=@cullent_attributes.column_names
                @ult_report_model.update_attributes(params[:ult_report_model])
                #@ult_report_model.update_attributes(:show_title=>"#{@columns.join(',')}")
                check_db_model
                @ult_report_model.update_attributes(:ultra_company_db_model_id=>@db_model.id.to_i)
                @tabmenu=FreedReport::Tabmenu.find(:last,:conditions=>"ult_report_model_id=#{@ult_report_model.id}")
                @tabmenu.update_attributes(:parent_id=>"#{params[:menu]}",:name=>@ult_report_model.name) if @tabmenu
                flash[:notice] ="报表模版修改成功"
                redirect_to :controller=>"freed_report/ult_freed_reports",:action => 'index' ,:report_id=>@ult_report_model.id
            rescue
              @un_conn_message +="请编写sql脚本；"  if params[:ult_report_model][:str_sql].to_s.include?"填写sql脚本注意事项"
              flash[:notice] = @un_conn_message+"报表模版sql语句有问题，请测试。"
              redirect_to :action => 'edit',:param=>params,:id=>params[:id]
            end
            @dbh.disconnect if @dbh
       end
     end
     
  end
  

  def destroy
     if params[:ids]
       @ult_report_models = FreedReport::UltReportModel.find(params[:ids].keys)
       @ult_report_models.each do |@ult_report_model|
         @ult_report_model.update_attributes(:top_style=>1)
         tabmenu=FreedReport::Tabmenu.find_by_name("#{@ult_report_model.name}")
         tabmenu.update_attributes(:top_style=>1) if tabmenu
       end
     else
         @ult_report_model = FreedReport::UltReportModel.find(params[:id])
         @ult_report_model.update_attributes(:top_style=>1)
         tabmenu=FreedReport::Tabmenu.find_by_name("#{@ult_report_model.name}")
         tabmenu.update_attributes(:top_style=>1) if tabmenu
     end
     flash[:notice] ="报表模版删除成功"
     redirect_to :action => 'index'
  end

  def mark_targs #搜索条件配置
      submenu_item "common_report"
      @ult_report_model = FreedReport::UltReportModel.find(params[:id])
      @my_params_first=@ult_report_model.form_title.split("￥") if @ult_report_model.form_title&&@ult_report_model.form_title!=""
      if params[:copy_model]
        #模版搜索条件复制
        @copy_report_model = FreedReport::UltReportModel.find(params[:copy_model].to_i)
        @my_params_first=@copy_report_model.form_title.split("￥") if @copy_report_model.form_title&&@copy_report_model.form_title!=""
        flash[:notice] ="您成功复制了模版:‘#{@copy_report_model.name}’相关搜索条件，请做相关修改参考。"
      end
  end

  def mark_create #检索配置更新
      @ult_report_model = FreedReport::UltReportModel.find(params[:id])
      @ultra_company_db_model=@ult_report_model.ultra_company_db_model
      @sql=params[:ult_report_model][:str_sql]
      @params_sql=params[:ult_report_model][:str_sql].dup
      @collect_items=params[:collect_item]
      @form_title=""
      @check_titles=[]
      @collect_items.each do|c|
        if c["name"]!=""&&c["cname"]!=""&&c["cname"]!="地市名称(测试)"
           c["source"]="" if c["source"]=="[['主城片区','主城片区'],['永川片区','永川片区']]"
           @form_title=@form_title+c["name"].lstrip+"#"+c["cname"].lstrip+"#"+c["singer"]+"#"+c["style"]+"#"+c["source"].lstrip+"#"+c["check"].lstrip+"￥"
           @check_titles<<[c["style"],c["name"].lstrip,c["singer"],c["check"].lstrip]
        end
      end
      unless @form_title==""
      @ult_report_model.update_attributes(:form_title=>@form_title)
      end
     begin
      db_connects("#{@ultra_company_db_model.db_style}","#{@ultra_company_db_model.db_con}","#{@ultra_company_db_model.db_user}","#{@ultra_company_db_model.db_password}")
      @dbh.execute("#{content_message(@sql)}")
      @ult_report_model.update_attributes(:str_sql=>@sql)
      @db_ok=1
      flash[:notice] ="检索配置更新成功" 
     rescue
      flash[:notice] = "报表模版sql语句有问题，请测试。"
     end
     
    if @dbh&&@db_ok
      flashback=[]
      @current_model=@ult_report_model
      for check_title in @check_titles
        if check_title[3]&&check_title[3]!=""
           begin
             @dbh.execute("#{content_message(check_title[3][4..-1])}") if (check_title[0]=="select" && check_title[3][0..3]=="sql=")
              if  check_title[0]=="time"
              option= Time.now.strftime("%Y-%m-%d")
              option= Time.now.strftime("%Y-%m-%d %H:%M:%S") if @ult_report_model.time_gran=="hour"
              else
              option="pk" #判空
              end
             @chenge_sql=has_compare_option?(@sql,check_title[0],check_title[1],check_title[2],check_title[3],option)
             @dbh.execute("#{content_message(@chenge_sql)}")
           rescue
             flashback<<check_title[1]
             flash[:notice] = "搜索条件配置有误，请查看相关选项。"
           end
        else
             flashback<<check_title[1]
             flash[:notice] = "搜索条件配置有误，请查看必填项是否填满。"
        end
      end
       if flashback==[]
       redirect_to :controller=>"freed_report/ult_freed_reports",:action => 'index' ,:report_id=>params[:id]
       else
       redirect_to :action => 'mark_targs',:id=>params[:id],:str_sql=>@params_sql,:flashback=>flashback
       end
    else
       redirect_to :action => 'mark_targs',:id=>params[:id],:str_sql=>@params_sql,:bad_sql=>1
    end
     @dbh.disconnect if @dbh
  end


  def check_worker#匹配数据源反馈致配置页面 ---2013-12-30---李江锋ljf
    if params[:idnum]&&params[:idnum]!=""
      @ultra_company_db_model=FreedReport::UltraCompanyDbModel.find(params["idnum"].to_i)
      params[:ultra_company_db_model_id]=params[:idnum]
      params[:db_name]=@ultra_company_db_model.db_name
      params[:db_user]=@ultra_company_db_model.db_user
      params[:db_style]=@ultra_company_db_model.db_style
      params[:db_password]=@ultra_company_db_model.db_password
      params[:db_port]=@ultra_company_db_model.db_port
      params[:db_host]=@ultra_company_db_model.db_host
      params[:db_service]=@ultra_company_db_model.db_service
    end
    render :partial => 'db_check'
  end

  def select_link_title
    #选择钻取报表列名称
    submenu_item "common_report"
    @ult_report_model = FreedReport::UltReportModel.find(params[:ult_report_model_id])
    @report_title=@ult_report_model.show_title.split(',')
  end

  def eare_check #根据所在省市定义导航起始编号
    @eare={"cn=yunnan" =>1,"cn=ningxia" =>[38.46,106.37],"cn=chongqing"=>[29.58,106.54],"cn=zhixiashi"=>[29.58,106.54],"cn=jiangxi"=>[28.64,115.89],"cn=hunan"=>[28.16,113.02],"cn=jilin" =>[43.78,125.37],"cn=shanxi"=>[37.87,112.55],"cn=hubei"=>[30.586854,114.276123]}
      {"cn=chongqing,c=cn"=>1,"cn=chongqing1,c=cn"=>5000}
  end

end

