# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#require 'casclient'
#require 'casclient/frameworks/rails/filter'
require 'casclient'
require 'casclient/frameworks/rails/filter'

class ApplicationController < ActionController::Base

  include DbQuery, ExternalAttrSupport

  include AuthenticatedSystem

  include AuthorizedSystem

  include OtherMod

  helper :all # include all helpers, all the time

  #protect_from_forgery :only => [:create, :update, :destroy]# See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  before_filter CASClient::Frameworks::Rails::Filter, :except => [:login, :logout]
  #  before_filter :login_required, :except => [:login]
  # before_filter :build_menu, :except => [:login, :logout]

  before_filter :set_current_user, :role_and_domain_required, :user_permissions, :build_menu, :except => [:login, :logout]

  before_filter :root_required, :except => [:login, :logout,:sessions]

  before_filter :site_tab,:sys_tab_check, :except => [:new, :edit,:destroy,:create,:update,:login, :logout,:sessions]

  before_filter :set_theme,:set_locale

  around_filter :set_language

  after_filter :log_operation, :except => [:new, :edit, :logout]

  def sys_tab_check
    current_menu=FreedReport::Tabmenu.find_by_url("#{request.request_uri[1..-1]}")
    session[:sys_tab]=current_menu.modelname if current_menu
  end
 

  def set_current_user
    User.current = current_user
  end

  def role_and_domain_required
    if
        current_user.nil? || current_user.role_id == -1 || current_user.domain_id == -1 || !current_user.role.present? || !current_user.domain.present?
      redirect_to  "/no_permission.html" and return
    end
  end

  def root_required
    unless ["sessions","personal", "dashboard","fault/summaries","inventory/search","value/regions"].include? params[:controller]
      if self.current_user.role_id !=1
        @role = System::Role.find(:last, :conditions => ["id = ?",self.current_user.role_id])
        unless Permission.find_by_sql("select id from sm_permissions where controller_name like '%#{params[:controller]}%' and action_name like '%#{params[:action]}%' and default_permission=false").empty?
          searched_permission = @role.permissions.select{|permission| ((permission.controller_name.include?(params[:controller].to_s))&(permission.action_name.include?(params[:action].to_s)))}
          if searched_permission.nil? || searched_permission.empty?
            redirect_to  "/no_permission.html" and return
          end
        end
      end
    end
  end

  def store_location
    session[:return_to] = request.request_uri unless request.request_uri.index("summaries")
  end

  def find_fitap_count
    # app = FitAp.find_by_sql("select count(*) num from mit_fit_aps t1
    #   where not exists (select 1 from mit_aps t2 where t1.ap_en = t2.ap_en and t1.ac_id = t2.ac_id)
    #   and t1.ap_dn like '%#{@current_user.domain.base}' and task_id is null")
    app = FitAp.find_by_sql("select count(*) num from mit_fit_aps t1
      where t1.ap_dn like '%#{@current_user.domain.base}' and task_id is null")
    # fat_app = FitAp.find_by_sql("select count(*) num from mit_fit_aps t1
    #   where not exists (select 1 from mit_aps t2 where t1.ap_en = t2.ap_en)
    #   and t1.ap_dn like '%#{@current_user.domain.base}' and task_id is not null")
    @fit_count=app[0].num unless app.nil?
    # @fat_count=fat_app[0].num unless fat_app.nil?
    flash[:fit_count] =  @fit_count
    # flash[:fat_count] =  @fat_count
  end

  def sysnote
    @appnote = Sysnote.find_by_sql("select * from sys_notes where now() between begin_time and end_time")
  end

  def title
    @title
  end

  def title=(title)
    @title = title
  end

  def log_operation
    if !session["flash"].blank? && !session["flash"][:failure].blank?
      result = "操作失败"
    else
      result = "操作成功"
    end
    details = session["flash"][:notice] unless session["flash"].blank?
    session["flash"][:failure] = "" unless session["flash"].blank?
    unless self.current_user.nil?
      Logm::OperationLog.new(
        :session =>session.session_id,
        :user =>self.current_user.id,
        :user_name =>self.current_user.login,
        :terminal_ip =>request.remote_ip,
        :module_name =>params[:controller],
        :action =>params[:action],
        :result =>result,
        :details =>details).save
    end
  end



  protected

  #TODO:
  def current_language
    :cn
  end

  #
  def with_some_columns(model_name, hsh)
    select_some = Hash.new
    columns = model_name.constantize.column_names
    columns.each {|c|
      if hsh.key?(c) && hsh[c]
        if hsh[c].class.eql?('String')
          select_some[c] = hsh[c] if hsh[c].length > 0 #去掉空字符串的�?
        else
          select_some[c] = hsh[c]
        end
      end
    }
    return select_some
  end

  def render_success(msg = "")
    render :text => {:success => true, :message => msg}.to_json
  end

  def render_failure(msg)
    render :status => "500 Internal Error", :text => {:success => false,
      :title => t('failure'), :message => msg}.to_json
  end

  def render_errors(model, errors)
    hash = Hash.new
    errors.each do |attr, msg|
      if model
        attr = "#{model}[#{attr}]"
      else
        attr = "#{attr}"
      end
      hash[attr] = msg.gsub(/'/,'"')  #TODO: ???
    end
    message = hash.values.join("<br>")
    render :text => {:success => false, :message => message, :title => t('failure'), :errors => hash}.to_json
  end
  protected

  def parse_sort sort
    return {:name =>nil,:direction =>nil } if(sort.nil? || sort.empty?)
    if sort[0]!=45
      direction = "ASC"
    else
      direction = "DESC"
      sort = sort.gsub(/^\-/,"")
    end
    {:name => sort,:direction => direction }
  end
  def order_option options = {},table_name = "",sort_attr=nil
    sort_attr ||= params[:sort]
    sort = parse_sort sort_attr
    table_name = (table_name.nil? || table_name.empty?) ? "" : table_name + "."
    unless sort[:name].nil?
      options.update(:order => "#{table_name}#{sort[:name]} #{sort[:direction]}")
    else
      options.update(:order => "#{table_name}id DESC")
    end
    options
  end

  def order_from_sort sort
    sort = parse_sort sort
    return nil if sort[:name].nil?
    "#{sort[:name]} #{sort[:direction]}"
  end

  #
  def set_theme
    @theme = 'blue'
    flash.keep(:fit_count)
    flash.keep(:fat_count)
  end

  def set_locale
    I18n.locale = "cn"
  end

  def set_language
    Gibberish.use_language(current_language) { yield }
  end

  def init_license
    domain = request.domain
    domain = request.host if domain.nil?
    $license = get_license(domain)
  end

  def get_license domain
    li = domain
    len = li.size.to_s(16)
    len = '0'+len if li.size<17
    li = (len+li).upcase
    t = ''
    0.upto(27-li.size) do
      t+='X'
    end
    li+=t+'5'
    x = "A9L2VJP1H-SR3NK68IWBDC05ZTOY.UEFG7XM4Q"
    y = li
    li=""
    0.upto(y.size-1) do |i|
      x = strrotate(x)
      c = y[i]
      l = x.index(c.chr)
      if (c>=65&&c<=90)
        li = li + x[c-65].chr
      elsif (c>=48&&c<=57)
        li = li + x[c-48+26].chr
      else
        li = li + x[c-45+36].chr
      end
    end
    l =0
    0.upto(li.size-1) do |i|
      l = l + li[i]
    end
    li = (6+70-l%10).chr + li
    li
  end

  def strrotate str
    str.slice(str.size-1).chr+str.slice(0,str.size-1)
  end

  def build_menu
#    return if request.xhr?
#    @current_menuitems = Menu.all.select do |m|
#      current_permissions.has_key?(m.url) && permits.include?(m.id)
#    end
   @current_menuitems=FreedReport::Tabmenu.menuitems
  end
  def user_permissions
    @user_permissions = []
    current_user.role.permissions.each do |p|
      user_p = []
      pcs= p.controller_name.split(",").to_a;
      pas=p.action_name.split(",").to_a;
      pcs.each do |pc|
        pas.each do |pa|
          user_p << pc+"/"+pa
        end
      end
      @user_permissions << user_p
      @user_permissions.uniq!
      @user_permissions.flatten!
    end
    return  @user_permissions
  end
  def record_memory
    process_status = File.open("/proc/#{Process.pid}/status")
    13.times { process_status.gets }
    rss_before_action = process_status.gets.split[1].to_i
    process_status.close
    yield
    process_status = File.open("/proc/#{Process.pid}/status")
    13.times { process_status.gets }
    rss_after_action = process_status.gets.split[1].to_i
    process_status.close
    logger.info("CONSUME MEMORY: #{rss_after_action - rss_before_action} \
                  KB\tNow: #{rss_after_action} KB\t#{request.url}")
  end

end
