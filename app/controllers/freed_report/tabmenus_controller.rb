class  FreedReport::TabmenusController < ApplicationController   #前置报表模版配置功能--2013-12-31版--李江锋ljf
  menu_item "freed_report"
  sidebar "freed_report"

  def index
    @tabmenu = FreedReport::Tabmenu.find_by_sql("select * from ultra_company_tabmenus where 1=1 order by parent_id desc , id")
    @grid = UI::Grid.new(FreedReport::Tabmenu, @tabmenu)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tabmenu }
    end
  end

  def new
    @tabmenu = FreedReport::Tabmenu.new
    respond_to do |format|
      format.html #new.html.erb
      format.xml {render :xml => @tabmenu}
    end
  end

   def create
     @tabmenu = FreedReport::Tabmenu.new(params[:tabmenu].except(:ultra_company_tabmenus_users))
     @tabmenu.user_id=current_user.id
     @tabmenu.top_style=0
     if @tabmenu.save
       if params[:tabmenu][:ultra_company_tabmenus_users]
       for use in params[:tabmenu][:ultra_company_tabmenus_users]
           tab_user=FreedReport::UltraCompanyTabmenusUser.new
           tab_user.ultra_company_tabmenu_id=@tabmenu.id
           tab_user.user_id=use.to_i
           tab_user.save
       end
       end
       if !params[:tabmenu][:modelname]||params[:tabmenu][:modelname]==""
        @tabmenu.modelname=@tabmenu.name
        @tabmenu.parent_id=nil
       else
          @tabmenu.parent_id=@tabmenu.id if !params[:tabmenu][:parent_id]||params[:tabmenu][:parent_id]==""
       end
       @tabmenu.save
        flash[:notice] ="导航配置配置创建成功"
        redirect_to :action => 'edit',:id=>@tabmenu.id
     end
   end

  def edit
     @tabmenu = FreedReport::Tabmenu.find(params[:id])
  end

   def show
    @tabmenu = FreedReport::Tabmenu.find(params[:id])
    respond_to do |format|
      format.html #edit.html.erb
      format.xml {render :xml => @tabmenu}
    end
  end

  def update
      @tabmenu = FreedReport::Tabmenu.find(params[:id])
       if !@tabmenu.parent_id||@tabmenu.parent_id==""
         @tabmenus = FreedReport::Tabmenu.find(:all,:conditions=>"modelname='#{@tabmenu.modelname}'")
         @tabmenus.each do |p|
           p.update_attributes(:modelname=>params[:tabmenu][:name])
         end
      end
      @tabmenu.update_attributes(params[:tabmenu].except(:ultra_company_tabmenus_users))
      sql=External.connection()
      sql.delete "delete from ultra_company_tabmenus_users where ultra_company_tabmenu_id=#{@tabmenu.id}"
      if params[:tabmenu][:ultra_company_tabmenus_users]
      for use in params[:tabmenu][:ultra_company_tabmenus_users]
           tab_user=FreedReport::UltraCompanyTabmenusUser.new
           tab_user.ultra_company_tabmenu_id=@tabmenu.id
           tab_user.user_id=use.to_i
           tab_user.save
       end
      end
       if !params[:tabmenu][:modelname]||params[:tabmenu][:modelname]==""
        @tabmenu.modelname=params[:tabmenu][:name]
        @tabmenu.parent_id=nil
       else
           if !params[:tabmenu][:parent_id]||params[:tabmenu][:parent_id]==""
             @tabmenu.parent_id=@tabmenu.id unless params[:tabmenu][:modelname]==params[:tabmenu][:name]
             @tabmenu.modelname=params[:tabmenu][:name]
           end
       end
       @tabmenu.save
      flash[:notice] ="导航菜单修改成功"
      redirect_to :controller=>"freed_report/tabmenus",:action => 'index' 
  end
  

  def destroy
     if params[:ids]
         @tabmenus = FreedReport::Tabmenu.find(params[:ids].keys)
       @tabmenus.each do |@tabmenu|
         @tabmenu.update_attributes(:top_style=>params[:top_style])
       end
     else
         @tabmenu = FreedReport::Tabmenu.find(params[:id])
         @tabmenu.update_attributes(:top_style=>params[:top_style])
     end

     flash[:notice] =params[:top_style]=="1" ? "菜单关闭成功" : "菜单开放成功"
     redirect_to :action => 'index'
  end

end

