class Report::AlarmTemplatesController < ApplicationController
  menu_item "report"
  sidebar "report"
  def index
    submenu_item "alarm_templates"
    if @current_user.login == 'root'
      @alarm_templates = Rms::ReportTemplate.paginate :conditions=>{:report_type=>2},:order=>'report_name' ,
        :page => params[:page],:per_page => 30
    else
      @create_user = Rms::ReportTemplate.find(:all).collect{|c| c.userid}
      @user_id = Rms::ReportTemplateUser.find(:all, :conditions => ["user_id = #{@current_user.id}"]).collect {|c| c.template_id}.join(",")
      @create_id = Rms::ReportTemplate.find(:all, :conditions => ["userid = #{@current_user.id}"]).collect {|c| c.id}.join(",")
      if !@user_id.nil? && !@create_id.nil? && @user_id.length > 0 && @create_id.length > 0
        @alarm_templates = Rms::ReportTemplate.paginate :conditions=>["report_type = 2 and (id in (#{@user_id}) or id in (#{@create_id}))"],:order=>'report_name' ,
          :page => params[:page],:per_page => 30
      elsif !@user_id.nil? && @user_id.length > 0 && @create_id.length < 1
        @alarm_templates = Rms::ReportTemplate.paginate :conditions=>["report_type = 2 and id in (#{@user_id})"],:order=>'report_name' ,
          :page => params[:page],:per_page => 30
      elsif !@create_id.nil? && @create_id.length > 0 && @user_id.length < 1
        @alarm_templates = Rms::ReportTemplate.paginate :conditions=>["report_type = 2 and id in (#{@create_id})"],:order=>'report_name' ,
          :page => params[:page],:per_page => 30
      else
        @alarm_templates = []
      end
    end
    @grid = UI::Grid.new(Rms::ReportTemplate, @alarm_templates)
    #    name = ["report_name","report_type","netloc_gran","time_gran"]
    #    @table = {
    #      :has_actions =>true,
    #      :column_display_names=>name,
    #      :model => Rms::ReportTemplate,
    #      :data => @alarm_templates
    #    }
    respond_to do |format|
      format.html #index.html.erb
      format.json { render :text=>list.to_json, :layout=>false }
    end
  end
  
  # GET /track_devices/1
  # GET /track_devices/1.xml
  def show
    submenu_item "alarm_templates"
    @alarm_templates = Rms::ReportTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alarm_templates }
    end
  end

  # GET /track_devices/new
  # GET /track_devices/new.xml
  def new
    submenu_item "alarm_templates"
    @all_users = User.all :conditions => ["id != #{@current_user.id}"]
    @perf_template = Rms::ReportTemplate.new
    @perf_template.apply_default_value(params)
  end

  # GET /track_devices/1/edit
  def edit
    submenu_item "alarm_templates"
    @all_users = User.all :conditions => ["id != #{@current_user.id}"]
    @perf_template = Rms::ReportTemplate.find params[:id]
  end

  # POST /track_devices
  def create
    submenu_item "alarm_templates"
    alarm_template = params[:alarm_template].update({:userid => session[:user_id], :cityid => @current_user.cityid})
    @perf_template = Rms::ReportTemplate.new_template(alarm_template.except(:chart_sets, :report_template_users))
    if @perf_template.save
      @perf_template.create_chart_set alarm_template[:chart_sets]
      @perf_template.create_template_user @current_user, alarm_template[:report_template_users]
      flash[:notice] = "创建告警报表模板成功"
      redirect_to :action => :index
    else
      flash[:failure] = flash[:notice] = "创建告警报表模板失败"
      @all_users = User.all
      @perf_template.adjust_attributes
      @perf_template.apply_default_value(params[:perf_template])
      render :action => :new
    end
  end

  # PUT /track_devices/1
  def update
    submenu_item "alarm_templates"
    alarm_template = params[:alarm_template]
    @perf_template = Rms::ReportTemplate.find params[:id]
    new_template = Rms::ReportTemplate.new_template(alarm_template.except(:chart_sets, :report_template_users))
    new_template.apply_creator(@current_user)
    if @perf_template.update_attributes(new_template.attributes)
      Rms::ReportTemplate.clear_associations params[:id]
      @perf_template.create_chart_set alarm_template[:chart_sets]
      @perf_template.create_template_user @current_user, alarm_template[:report_template_users]
      flash[:notice] = "修改告警报表模板成功"
      redirect_to :action => :index
    else
      flash[:failure] = flash[:notice] = "修改告警报表模板失败"
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
        flash[:notice] = "删除告警报表模板成功"
        format.html { redirect_to :action => 'index' }
        format.xml  { head :ok }
      else
        flash[:failure] = flash[:notice] = "删除告警报表模板失败"
        format.html { redirect_to :action => 'index'}
        format.xml { render :xml => @alarm_templates.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  def get_condition(option)
    conditionStr = "1 = 1"
    groupStr = ""
    cityid = nil
    if option[:port_type]
      groupStr = groupStr + " port_type,"
      if option[:port_type].length > 0 && option[:port_type].to_i > 0
        conditionStr = conditionStr + " and port_type = #{option[:port_type].to_i}"
      end
    end
    if option[:device_type]
      groupStr = groupStr + " device_type,"
      if option[:device_type].length > 0 && option[:device_type].to_i > 0
        conditionStr = conditionStr + " and device_type = #{option[:device_type].to_i}" 
      end
    end
    if option[:device_manu]
      groupStr = groupStr + " device_manu," 
      if option[:device_manu].length > 0 && option[:device_manu].to_i > 0
        conditionStr = conditionStr + " and device_manu = #{option[:device_manu].to_i}"
      end
    end
    if option[:porttype]
      if option[:porttype].length > 0
        conditionStr = conditionStr + " and porttype = #{option[:porttype].to_i}"
      end
    end
    if option[:areas] && option[:areas].length > 0
      areas = option[:areas].split(',')

      areaCond = '( 1 <> 1 '
      areas.each do |a|
        type_id = a.split('_')
        type = type_id[0]
        id = type_id[1]
        case type
        when 'Area'
          area = area_select(id)
          node_type = area.nodetype
          if node_type == 1  #city
            name = 'cityid'
            cityid = id
          elsif node_type == 2 #town
            name = 'town'
          elsif node_type == 5 #port
            name = 'port'
          end
          areaCond = areaCond + " or #{name} = #{id}"
        end
      end
      areaCond = areaCond + ' )'
      conditionStr = conditionStr + " and " + areaCond
    end
    return {:where => conditionStr, :group => groupStr, :city => cityid}
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
