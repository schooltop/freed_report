class Report::SpecialController < ApplicationController
  menu_item "report"
  
  def index
    submenu_item "special"
    data = {:url=>'/report/special/ap_info',:pageable=>true,:page_size=>60 ,:checkable=>true,
      :columns => [{:dataIndex => 'id',:header => '编号',:sortable => true },
        {:dataIndex => 'ip',:header => 'IP地址',:sortable => true },
        {:dataIndex => 'nodecn',:header => 'ap名称',:sortable => true },
        {:dataIndex => 'power',:header => '功率(mw)',:sortable => true },
        {:dataIndex => 'floorcn',:header => '设备型号',:sortable => true },
        {:dataIndex => 'buildingcn',:header => '设备厂家',:sortable => true },
        {:dataIndex => 'portcn',:header => '所属热点',:sortable => true },
        {:dataIndex => 'address',:header => '地址',:sortable => true }] ,
      :operations =>[{:name=>'import',:text=>'导入',:iconCls=>'grid-import-button',:func=>'onImport',:url=>'',:group=>'default'},
        {:name=>'refresh',:text=>'刷新',:iconCls=>'grid-refresh-button',:func=>'refresh',:url=>'',:group=>'default'},
        {:name=>'delete',:text=>'删除',:iconCls=>'grid-delete-button',:func=>'doDelete',:url=>'',:method=>'Delete',:group=>'default'}]}
    respond_to do |format|
      format.html{@config = data.to_json}
      format.json {render :json=>list.to_json, :layout=>false }
    end
  end
  
  #POST
  def create
    case_ap = Rms::CaseAp.find(:first,:conditions=>"case_id = '#{params[:case_id]}'")
    if case_ap
      render_failure('请选择专案组或删除该专案的AP')
      return 
    end
    special_case = Rms::CaseGroup.new({:case_name=>params[:case_name],:parent_id=>params[:case_id],:cityid=>@current_user.cityid})
    if special_case.save
      special_case.reload
      #建立用户专案关系
      Rms::CaseUser.new({:cityid=>@current_user.cityid,:user_id=>session[:user_id],:case_id=>special_case.id}).save  if session[:user_id] !=1
      user_ids = params[:case_user].split(',')
      if user_ids
        user_ids.each do |user_id|
          case_group(special_case.id,user_id,@current_user.cityid)
        end
      end
      node = {:text=> special_case.case_name ,:id=>special_case.id.to_s,:cls=> "folder", :iconCls=>"newNode",:leaf=>true}
      render :text =>{:success => true,:node=>node}.to_json
    else
      render_errors(false, special_case.errors)
    end
  end
  
  def case_group(case_id,user_id,area_id)
    case_user = Rms::CaseUser.find(:all,:conditions=>"case_id = #{case_id} and user_id = #{user_id}")
    if case_user && case_user.empty?
      Rms::CaseUser.new({:cityid=>area_id,:user_id=>user_id,:case_id=>case_id}).save 
      case_current = Rms::CaseGroup.find(case_id)
      if case_current && case_current.parent_id != -1 #为防止上面查询报错
        case_group(case_current.parent_id,user_id,area_id)  
      end
    end
  end
  
  #put
  def update
    special_case = Rms::CaseGroup.find(params[:id])
    if special_case.update_attributes({:case_name=>params[:case_name]})
      #ToDo 未进行改节点 的冒泡节点 用户关系删除
      Rms::CaseUser.delete_all("case_id = #{params[:id]}")
      #建立用户专案关系
      Rms::CaseUser.new({:cityid=>@current_user.cityid,:user_id=>session[:user_id],:case_id=>special_case.id}).save  if session[:user_id] !=1
      user_ids = params[:case_user].split(',')
      if user_ids
        user_ids.each do |user_id|
          case_group(special_case.id,user_id,@current_user.cityid)
        end
      end
      render :text =>{:success => true,:case_name=>special_case.case_name}.to_json
    else
      render_errors(false, special_case.errors)
    end
  end
  
  #delete
  def destroy
    if Rms::CaseGroup.delete(params[:id])
      Rms::CaseUser.delete_all("case_id = #{params[:id]}")
       Rms::CaseAp.delete_all("case_id = #{params[:id]}")
       flash[:notice] = "删除成功"
      render :text =>{:success => true,:case_id=>params[:id]}.to_json
    else
      flash[:failure] = flash[:notice] = "删除失败"
      render_failure('删除失败')
    end
  end
  
  def import
    #不存在的ip值
    message = []
    begin
      CSV::Reader.parse(params[:attachment][:uploaded_data]) do |row|
        if row[0]
          device_info = DeviceInfo.find(:first, :select=>"id",:conditions=>"ip = '#{row[0].strip}' and nodetype = 11")
          if device_info
            case_ap = Rms::CaseAp.find(:first,:conditions=>"case_id = '#{params[:case_id]}' and ap = '#{device_info.id}'")
            Rms::CaseAp.new({:cityid => @current_user.cityid,:case_id => params[:case_id],:ap => device_info.id}).save unless case_ap
          else
            message << 'IP:'+row[0]+'不存在'
          end
        end
      end
    rescue
      render_failure('导入失败')
      return
    end
    if message.empty?
      render_success
    else
      render_success(message.join('<br>'))
    end
  end
  
  
  def delete_ap
    if Rms::CaseAp.delete_all("ap in (#{params[:id]}) and case_id = #{params[:case_id]}")
      render_success
    else 
      render_failure('删除失败')
    end
  end
  
  #检查文件，是否存在、格式
  def check_file(file)
    if File.exist?(file)
      if (File.extname(file).eql?('.txt')) or (File.extname(file).eql?('.csv'))
        return true
      end
    end
    return false
  end
      
  
  def ap_info
    aps = DeviceInfo.find_by_sql("select t1.id,t1.nodecn,t1.ip,t1.power,t2.remark floorcn,t3.remark buildingcn,
                                t1.portcn,t1.ADDRESS 
                                from device_infos t1,dic_codes t2,dic_codes t3
                                where t1.DEVICE_TYPE = t2.id(+)
                                and t1.DEVICE_MANU = t3.id(+)
                                and t1.NODETYPE = 11 and t1.id in (select ap from wlan_case_aps where case_id ='#{params[:case_id]}')")
    render :text => {:total =>aps.size,:data =>aps}.to_json, :layout => false
  end
  
  def case_user
    users = User.find(:all,:conditions=>"id <> #{session[:user_id]} and id <> 1")
    user_info = users.collect{|u| { :id => u.id, :name => u.name } } if users
    if user_info
      render :json => {:total => user_info.size, :data => user_info}.to_json
    else
      render :json => user_info.to_json
    end  
  end

  def case_tree
    tree_data = case_tree_node(-1)
    render :json => tree_data.to_json, :layout => false
  end
  private
  def list
    case_group = Rms::CaseGroup.find(params[:id])
    case_user = Rms::CaseUser.find(:all,:select=>'user_id',:conditions=>"case_id = #{params[:id]}")
    case_user_id = case_user.collect {|c| c.user_id}.join(',')
    {:data=>[{:case_name=>case_group.case_name,:case_user => case_user_id }]}
  end
  def case_tree_node(parent_id)
    if  session[:user_id] == 1 || parent_id == -1
      case_groups = Rms::CaseGroup.find(:all,:conditions=>"parent_id = #{parent_id}")
    else
     case_groups = Rms::CaseGroup.find(:all,
          :joins =>"left join wlan_case_users on wlan_case_groups.id = wlan_case_users.case_id",
          :conditions => "wlan_case_users.user_id = '#{session[:user_id]}' and wlan_case_groups.parent_id = #{parent_id}")  
    end
    data = []
    if case_groups
      case_groups.each do |case_group|
        if Rms::CaseGroup.find_by_parent_id(case_group.id)
          data << {"leaf" => false,"text" =>case_group.case_name,"id" => case_group.id.to_s,"cls" => "folder","iconCls" =>"areaNode",
                    "expanded"=>true,"children" => case_tree_node(case_group.id)}
        else
          data << {"leaf" => true,"text" =>case_group.case_name,"id" => case_group.id.to_s,"iconCls" =>"areaNode","expanded"=>true}
        end
      end
    end
    data
  end
end
