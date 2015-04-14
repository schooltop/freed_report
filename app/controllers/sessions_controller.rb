# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  skip_before_filter :login_required,:find_fitap_count

  skip_before_filter :permit_required
  
  skip_before_filter :build_menu,:user_permissions, :except => [:logout]
  
  skip_filter :log_operation

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      session[:uid] = user.id
      session[:login] = user.login
      session[:name] = user.name
      session[:login_time] =Time.now
      session[:ip] = request.remote_ip
#      session[:base] = user.domain.base
      self.current_user = user
      @current_user = user
      User.current = @current_user

      #登陆成功直接保存安全日志
      Logm::SecurityLog.new(
        :session => session.session_id,
        :user =>user.id,
        :user_name =>user.login,
        :terminal_ip =>request.remote_ip,
        :host_name =>request.env["HTTP_HOST"],
        :security_cause =>"登录成功.",
        :security_action =>params[:controller]+'/'+params[:action],
        :result => '登录成功',
        :created_at => Time.now,
        :details =>"登录成功").save
      
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      
      #登陆失败需要判断用户名是否存在
    else
      if params[:login]
      user = User.find(:first, :conditions =>["login = '#{params[:login]}'"])
        if user
          user_id = user.id
          user_name = user.login
          details = "密码错误"
          security_cause = "登录失败."
        else
          user_id = ""
          user_name = params[:login]
          details = "用户名不存在"
          security_cause = "登录失败."
        end
        Logm::SecurityLog.new(
          :session => session.session_id,
          :user => user_id,
          :user_name => user_name,
          :terminal_ip =>request.remote_ip,
          :host_name =>request.env["HTTP_HOST"],
          :security_cause =>security_cause,
          :security_action =>params[:controller]+'/'+params[:action],
          :result => '登录失败',
          :created_at => Time.now,
          :details => details).save
      end
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = I18n.t "logged_out"
    redirect_back_or_default('/')
  end

  def logout
    user = User.find(params[:id])
    Logm::SecurityLog.new(
    :session => session.session_id,
    :user =>user.id,
    :user_name =>user.login,
    :terminal_ip =>request.remote_ip,
    :host_name =>request.env["HTTP_HOST"],
    :security_cause =>"登出成功",
    :security_action =>params[:controller]+'/'+params[:action],
    :result => '登出成功',
    :created_at => Time.now,
    :details =>"登出成功").save
    #TODO: should reset session?
    session[:logout_time] = Time.now
#    session[:uid] = nil
    reset_session
    redirect_to :action =>'new'
  end
  
protected
  # Track failed login attempts
  def note_failed_signin
    flash[:notice] = I18n.t "login_failure"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
