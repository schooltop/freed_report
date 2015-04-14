class UsersController < Security::BaseController

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  sidebar "system"
  before_filter :login_required
  before_filter :update_user, :only => [:edit]
  before_filter :roles_and_domains, :only => [:new,:edit,:create,:update]
  skip_filter :log_operation, :only => [:reset_pwd]
  skip_before_filter CASClient::Frameworks::Rails::Filter, :except => [:index]
  def index
    submenu_item "users"
    if !params[:sort].nil?
      if params[:sort][0] == 45
        sort = params[:sort][1,params[:sort].length-1]
        rise = "DESC"
      else
        sort = params[:sort]
        rise = "ASC"
      end
    end
    @users = User.paginate query_options(sort, rise)
    # if !params[:sort].nil?
    #   # @users = User.paginate :joins => " join (select * from sm_domains where base like '%#{@current_user.domain.base}') a on a.id=users.domain_id ", 
    #   @users = User.paginate :select => "t1.name domain_name, t1.base domain_base, t2.name role_name, users.*",
    #                          :joins => "left join sm_domains t1 on t1.id = users.domain_id and t1.base like '%c=cn'
    #                                     left join sm_roles t2 on t2.id = users.role_id",
    #                          :page => params[:page],
    #                          :per_page => 30,
    #                          :order => "#{sort} #{rise}"
    # else
    #   # @users = User.paginate :joins=>" join (select * from sm_domains where base like '%#{@current_user.domain.base}') a on a.id=users.domain_id  ", 
    #   #                        :page => params[:page],
    #   #                        :per_page => 30
    #   @users = User.paginate :select => "t1.name domain_name, t1.base domain_base, t2.name role_name, users.*",
    #                          :joins => "left join sm_domains t1 on t1.id = users.domain_id and t1.base like '%c=cn'
    #                                     left join sm_roles t2 on t2.id = users.role_id",
    #                          :page => params[:page],
    #                          :per_page => 30
    # end
    #    domain = @current_user.domain.base.split(',').length
    #    @users.delete_if do|user|
    #      用户分域
    #      (user.domain.base.split(',').length <= domain) & (!(user.domain.base==@current_user.domain.base))
    #    end
    @grid = UI::Grid.new(User, @users)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # render new.rhtml
  def new
    submenu_item "create_user"
    @user = User.new
    respond_to do |format|
      format.html #new.html.erb
      format.xml {render :xml => @user}
    end
  end

  def edit
    submenu_item "users"
    @domains = Domain.find_by_sql("select * from sm_domains where base like '%#{@current_user.domain.base}'").collect {|c| [c.name,c.id]}.uniq
    @roles = System::Role.find_by_sql("select t1.role_id id,t3.name from
    (select a1.role_id,count(*) permission_num from sm_roles_permissions a1
    where a1.permission_id in (select permission_id from sm_roles_permissions where role_id =#{@current_user.role_id})
    group by a1.role_id) t1,
    (select role_id,count(*) permission_num from sm_roles_permissions group by role_id) t2,
    sm_roles t3
    where t1.permission_num = t2.permission_num and t1.role_id = t2.role_id
    and t1.role_id = t3.id ").collect { |c|
      if c.name == "admin"
        ["系统管理员",c.id]
      else
        [c.name,c.id]
      end}.uniq
    @user = User.find(params[:id])
    respond_to do |format|
      format.html #edit.html.erb
      format.xml {render :xml => @user}
    end
  end

  def update
    submenu_item "users"
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = @user.login + '修改成功'
      redirect_to :action => 'index'
    else
      flash[:failure] = flash[:notice] = @user.login + '修改失败'
      render :action => 'edit'
    end
  end

  def create
    submenu_item "create_user"
    login = params[:user][:login]
    @user = User.new(params[:user])
    if login && login.start_with?("@")
      flash[:failure] = flash[:notice] = "用户名格式错误"
      render :action => "new"
    else
      success = @user && @user.save
      if success && @user.errors.empty?
        flash[:notice] = @user.login + "创建成功"
        redirect_to :action => "index"
      else
        flash[:failure] = flash[:notice]  = @user.login + "创建失败"
        render :action => 'new'
      end
    end
  end

  def edit_password
    submenu_item "users"
    if !params[:ids].nil?
      ids = params[:ids].keys[0]
    elsif !params[:id].nil?
      ids = params[:id]
    end
    con = "id = #{ids}"
    @user = User.find(:first,:conditions => con)
    respond_to do |format|
      format.html #edit_password.html.erb
      format.xml {render :xml => @user}
    end
  end

  def update_password
    submenu_item "users"
    @user = User.find(params[:id])
    if params[:old_password].empty? || params[:password].empty? || params[:password_confirmation].empty?
      flash[:failure] = flash[:notice] = "密码不能为空!"
      redirect_to :action => 'edit_password', :id => @user.id
    else
      if params[:old_password].length < 6 || params[:password].length < 6 || params[:password_confirmation].length < 6
        flash[:failure] = flash[:notice] = "密码太短"
        redirect_to :action => "edit_password", :id => @user.id
      elsif params[:old_password].length > 40 || params[:password].length > 40 || params[:password_confirmation].length > 40
        flash[:failure] = flash[:notice] = "密码太长"
        redirect_to :action => "edit_password", :id => @user.id
      else
        if !User.authenticate(@user.login, params[:old_password])
          flash[:failure] = flash[:notice] = "原密码错误!"
          render :action => 'edit_password', :id =>@user.id
        elsif params[:password] != params[:password_confirmation]
          flash[:failure] = flash[:notice] = "新密码与确认密码不一致!"
          render :action => 'edit_password', :id => @user.id
        elsif @user.update_attributes!(:password => params[:password],:password_confirmation => params[:password_confirmation])
          flash[:notice] = "密码修改成功!"
          redirect_to :action => 'index'
        else
          flash[:failure] = flash[:notice] = "修改密码失败!"
          render :action => 'edit_password', :id => @user.id
        end
      end
    end
  end
  
  def reset_pwd
    submenu_item "users"
    if !params[:ids].nil?
      ids = params[:ids].keys[0]
    elsif !params[:id].nil?
      ids = params[:id]
    end
    con = "id = #{ids}"
    @user = User.find(:first, :conditions => con)
    respond_to do |format|
      format.html #reset_pwd.html.erb
      format.xml {render :xml => @user}
    end
  end

  def reset_password
    submenu_item "users"
    @user = User.find(params[:id])
    if params[:password].empty? || params[:password_confirmation].empty?
      flash[:failure] = flash[:notice] = "密码不能为空。"
      redirect_to :action => 'reset_pwd', :id => @user.id
    else
      if params[:password].length < 6 || params[:password_confirmation].length < 6
        flash[:failure] = flash[:notice] = "密码太短。"
        redirect_to :action => 'reset_pwd', :id => @user.id
      elsif params[:password].length > 40 || params[:password_confirmation].length > 40
        flash[:failure] = flash[:notice] = "密码太长。"
        redirect_to :action => 'reset_pwd', :id => @user.id
      else
        if params[:password] != params[:password_confirmation]
          flash[:failure] = flash[:notice] = "两次输入密码不一致。"
          redirect_to :action => 'reset_pwd', :id => @user.id
        elsif @user.update_attributes!(:password => params[:password],:password_confirmation => params[:password_confirmation])
          flash[:notice] = "密码重置成功。"
          redirect_to :action => 'index'
        else
          flash[:failure] = flash[:notice] = "密码重置失败。"
          redirect_to :action => 'reset_pwd', :id => @user.id
        end
      end
    end
  end

  def destroy
    ids = params[:id] || params[:ids]
    ids = ids.keys if !ids.nil? and ids.is_a?(Hash)
    unless ids.nil?
      if ids.is_a?(Array)
        id = ids.join(",")
      elsif ids.is_a?(String)
        id = ids
      end
      if ids.to_a.include?(User.root.id.to_s)
        flash[:failure] = flash[:notice] = "不能删除root用户"
        redirect_to :action => 'index'
      elsif ids.to_a.include?(self.current_user.id.to_s)
        flash[:failure] = flash[:notice] = "不能删除当前用户"
        redirect_to :action => 'index'
      elsif User.delete(ids) && Rms::ReportTemplateUser.delete_all("user_id in (#{id})")
        flash[:notice] = "删除用户成功"
        redirect_to :action => 'index'
      else
        flash[:failure] = flash[:notice] = "删除用户失败"
        redirect_to :action => 'index'
      end
    else
      flash[:failure] = flash[:notice] = "请选择用户"
      redirect_to :action => "index"
    end
  end

  private
  def roles_and_domains
    @domains = Domain.find_by_sql("select * from sm_domains where base like '%#{@current_user.domain.base}'")
    @domains = @domains.collect {|c| [c.name,c.id]}.uniq
    @roles = System::Role.find_by_sql("select t1.role_id id,t3.name from
    (select a1.role_id,count(*) permission_num from sm_roles_permissions a1
    where a1.permission_id in (select permission_id from sm_roles_permissions where role_id =#{@current_user.role_id})
    group by a1.role_id) t1,
    (select role_id,count(*) permission_num from sm_roles_permissions group by role_id) t2,
    sm_roles t3
    where t1.permission_num = t2.permission_num and t1.role_id = t2.role_id
    and t1.role_id = t3.id ").collect { |c|
      if c.name == "admin"
        ["系统管理员",c.id]
      else
        [c.name,c.id]
      end}.uniq
  end

  def update_user
    @user = User.find(params[:id])
    if @user.login == 'root' && @current_user.login != 'root'
      flash[:notice] = "你不是root用户不能修改root用户"
      redirect_to :action => "index"
    elsif @user.login != 'root' && @user.id == @current_user.id
      flash[:notice] = "你不是root用户不能修改自己的信息"
      redirect_to :action => 'index'
    end
  end

  def query_options sort, rise
    options = {} 
    options[:select] = "t1.name domain_name, t1.base domain_base, t2.name role_name, users.*"
    options[:joins] = "left join sm_domains t1 on t1.id = users.domain_id and t1.base like '%#{@current_user.domain.base}' left join sm_roles t2 on t2.id = users.role_id"
    options[:page] = params[:page]
    options[:per_page] = 30
    options[:order] = "#{sort} #{rise}" unless params[:sort].nil?
    # 旧的语句 同时没有select
    # options[:joins] = "join (select * from sm_domains where base like '%#{@current_user.domain.base}') a on a.id=users.domain_id"
    # options[:page] = params[:page]
    # options[:per_page] = 30
    # options[:order] = "#{sort} #{rise}" unless params[:sort].nil?
    options
  end
end
