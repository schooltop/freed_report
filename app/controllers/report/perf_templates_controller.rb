class Report::PerfTemplatesController < ApplicationController
  sidebar "report"
  menu_item "report"
  before_filter :check_sort, :only => [:index]
  before_filter :load_enum_options, :only => [:new, :edit, :create, :update]
  def check_sort
    params[:sort] ||= 'report_name'
    params[:sort_direction] ||= 'ASC'
    sort = parse_sort params[:sort]
    @order_by = "#{sort[:name]} #{sort[:direction]}"
  end
  
  def index
    submenu_item "perf_templates"    
    if @current_user.login == 'root'
      @perf_templates = Rms::ReportTemplate.paginate :conditions=>{:report_type=>1},:order=>@order_by ,
        :page => params[:page] || 1,:per_page => 30
    else
      current_user = @current_user
      cond = Rms::ReportTemplate.ez_condition do
        report_type  == 1
        condition(:wlan_rms_template_users) do
          user_id == current_user.id
        end
      end
      @perf_templates = Rms::ReportTemplate.paginate :joins => :report_template_users,
        :conditions=>cond.to_sql,:order=>@order_by ,
        :page => params[:page] || 1,:per_page => 30
    end



    @grid = UI::Grid.new(Rms::ReportTemplate, @perf_templates)
    respond_to do |format|
      format.html #index.html.erb
      format.json { render :text=>list.to_json, :layout=>false }
    end
  end
  
  # GET /track_devices/new
  # GET /track_devices/new.xml
  def new
    submenu_item "perf_templates"
    @all_users = User.all :conditions => ["id != #{@current_user.id}"]
    @perf_template = Rms::ReportTemplate.new
    @perf_template.apply_default_value(params)
  end

  def domains
    puts "******************************perf_templates**************************:#{params[:parent]},#{params[:netloc]},#{params[:level]}"
    render :status => 200, :json => Rms::ReportTemplate.domains_tree(@current_user,params[:parent],params[:netloc],params[:level])
  end

  def kpilist_candidate
    render :status => 200, :json => Rms::ReportTemplate.index_type(params[:netgran])
  end
  
  # GET /track_devices/1/edit
  def edit
    submenu_item "perf_templates"
    @all_users = User.all :conditions => ["id != #{@current_user.id}"]
    @perf_template = Rms::ReportTemplate.find params[:id]
    @perf_template.apply_default_value(params)
  end
  
  # POST /track_devices
  # POST /track_devices.xml
  def create
    submenu_item "perf_templates"
    perf_template = params[:perf_template].merge!({:userid => session[:user_id], :cityid => @current_user.cityid})
    @perf_template = Rms::ReportTemplate.new_template(perf_template.except(:temp_user, :chart_sets, :report_template_users))
    @perf_template.apply_dic_group_conditions(perf_template[:group_original])
    @perf_template.apply_creator(@current_user)
    if @perf_template.save
      @perf_template.create_chart_set perf_template[:chart_sets]
      @perf_template.create_template_user @current_user, perf_template[:report_template_users]
      flash[:notice] = "创建性能报表模板成功"
      redirect_to :action => :index
    else
      flash[:failure] = flash[:notice] = "创建性能报表模板失败"
      @all_users = User.all
      @perf_template.adjust_attributes
      @perf_template.apply_default_value(params[:perf_template])
      render :action => :new
    end
  end
  
  # PUT /track_devices/1
  # PUT /track_devices/1.xml
  def update
    submenu_item "perf_templates"
    perf_template = params[:perf_template]
    @perf_template = Rms::ReportTemplate.find params[:id]
    new_template = Rms::ReportTemplate.new_template(perf_template.except(:chart_sets, :report_template_users))
    new_template.apply_creator(@current_user)
    new_template.apply_dic_group_conditions(perf_template[:group_original])
    if @perf_template.update_attributes new_template.attributes
      flash[:notice] = "修改性能报表模板成功"
      Rms::ReportTemplate.clear_associations params[:id]
      @perf_template.create_chart_set perf_template[:chart_sets]
      @perf_template.create_template_user @current_user, perf_template[:report_template_users]
      redirect_to :action => :index
    else
      flash[:failure] = flash[:notice] = "修改性能报表模板失败"
      @all_users = User.all
      @perf_template.adjust_attributes
      @perf_template.apply_default_value(params[:perf_template])
      render :action => :edit
    end
  end
  
  # DELETE /track_devices/1
  # DELETE /track_devices/1.xml
  def destroy
    ids=params[:ids] || params[:id]
    ids = ids.keys if !ids.nil? and ids.is_a?(Hash)
    respond_to do |format|
      if Rms::ReportTemplate.delete(ids)
        Rms::ReportTemplate.clear_associations ids
        flash[:notice] = "删除性能报表模板成功"
        format.html { redirect_to :action => 'index' }
      else
        flash[:failure] = flash[:notice] = "删除性能报表模板失败"
        format.html { redirect_to :action => 'index'}
      end
    end
  end
  
  private

  def load_enum_options
    @template_catetory = Rms::Category.all.collect{|c| [c.category_name, c.id] }
    @group_types = [["普通报表", "3"], ["常用报表", "2"], ["集团报表", "1"]]
    @busi_types  = [["性能报表", "1"], ["业务报表", "2"]]
  end

  def area_select(aid)
    area = DeviceInfo.find_by_sql("select  id,nodetype from device_infos where id = #{aid}")
    return area.first      
  end
  
  def list
    template = Rms::ReportTemplate.find(params[:id])
    tem_attr = template.attributes
    netloc = template.netloc
    netloc_type = netloc
    #treefield
    net_value = []
    if netloc&&netloc.index('(')
      netloc_area = netloc[netloc.index('(')+1..netloc.index(')')-1].split('or')
      netloc_type = netloc[0,netloc.index('(')]
      net_value = netloc_area.map do |stra| 
        arya = stra.split('=')
        if arya[1]
          "Area_" +arya[1].strip
        end
      end
    end
    tem_attr['areas'] = net_value.compact.join(',')
    #checkcombo
    if netloc_type && netloc_type.include?('and')
      netloc_type.split('and').each do |n| 
        unless n.strip.empty?
          ary = n.split('=') 
          tem_attr[ary[0].strip+'_cc'] = ary[1].strip
        end
      end
    end
    
    netloc_group = template.dic_group
    if netloc_group
      netloc_group.split(',').each do |g|
        unless g.strip.empty?
          unless tem_attr[g.strip+'_cc']
            tem_attr[g.strip+'_cc'] = 0 #默认为全�?          end
          end
        end
      end
      #temp_user
      user_ids = Rms::ReportTemplateUser.find(:all,:select=>'user_id',:conditions=>"template_id = #{params[:id]}").collect{|tem_user| tem_user.user_id}
      tem_attr['temp_user'] = user_ids.join(',')
      #chart
      chart_sets = template.chart_sets.find(:all,:order=>'chart_seq')
      if chart_sets
        tem_attr['chart_sets'] = chart_sets.length
        chart_sets.each do |chart_set|
          chart_name = 'chart'+chart_set.chart_seq.to_s+'chart_name'
          chart_type = 'chart'+chart_set.chart_seq.to_s+'chart_type'
          chart_x_col = 'chart'+chart_set.chart_seq.to_s+'x_col'
          chart_group_col = 'chart'+chart_set.chart_seq.to_s+'group_col'
          tem_attr[chart_name] = chart_set.chart_name
          tem_attr[chart_type] = chart_set.chart_type
          tem_attr[chart_x_col] = chart_set.x_col
          tem_attr[chart_group_col] = chart_set.group_col
        end
      end
      {:total => 1, :data => [tem_attr]}
    end
  end
end
