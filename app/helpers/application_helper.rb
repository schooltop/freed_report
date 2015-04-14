# Methods added to this helper will be available to all templates in the application.
#require 'fusioncharts_helper.rb'
#include FusionChartsHelper
module ApplicationHelper
#  include OtherMod
#   SiteTabs.each do |m|
#    define_method("#{m}_title_select") do |*arg|
#      title,link,same = arg[0],arg[1],arg[2]||arg[0].to_s
#      title_select t(title),link,same,session["#{m}_tab".to_sym],m
#    end
#   end
#   def title_select(tab_title,link,same,sess,m)
#       s = same != sess ? "" : "class='current'"
#       df = same != sess ? "notCurrent" : "current"
#       if same != sess
#       img ="<img src='/stylesheets/themes/ultrapower/images2/menu_t.jpg' alt='#{tab_title}' border='0' align='absmiddle' style='margin-right:8px'>" if m == "site"
#       "<li #{s}><a  href='/#{link}'>#{img}#{tab_title}</a></li>"
#       else
#       img ="<img src='/stylesheets/themes/ultrapower/images2/menu_t_current.jpg' alt='#{tab_title}' border='0' align='absmiddle' style='margin-right:8px'>" if m == "site"
#       "<li #{s}><a  href='/#{link}'>#{img}<font color='#ffffff'>#{tab_title}</font></a></li>"
#       end
#   end

  def lat_lon(domain)
    lat_lon = {"cn=yunnan" =>[26.1,102.7],"cn=ningxia" =>[38.46,106.37],"cn=chongqing"=>[29.58,106.54],"cn=zhixiashi"=>[29.58,106.54],"cn=jiangxi"=>[28.64,115.89],"cn=hunan"=>[28.16,113.02],"cn=jilin" =>[43.78,125.37],"cn=shanxi"=>[37.87,112.55],"cn=hubei"=>[30.586854,114.276123]}
    base = domain.base.split(",").reverse
    return lat_lon[base[1]].nil?? "cn=yunnan":lat_lon[base[1]]
  end

  def controlled(url)
    if( @user_permissions.include?(url) || @current_user.id==1)
      # if( @user_permissions.include?(url))
      return "  "
    else
      return " access_controlled"
    end
  end

  def dic_code_label id
    id = id.to_s
    if id and !id.empty?
      code = Dic::Code.find_by_id(id)
      return code.code_label if code
      return ""
    end
  end
  def is_permited(url)
    current_permissions.has_key? url
  end

  #  #select navigation
  #  def menu(menu_id, name, options={}, html_options={:class=>''}, &block)
  #    class_name = nil
  #    class_name = 'ui-corner-top ui-state-active' if @menu_id == menu_id
  #    content_tag(:li, link_to(name,options,html_options,&block), :class=>class_name)
  #  end
  #
  #  def submenu(submenu_id, name, options={}, html_options={:class => ''}, &block)
  #    class_name = ''
  #    class_name = 'current ui-state-default' if (@submenu_id == submenu_id)
  #    content_tag(:li, link_to(name, options, html_options, &block), :class => class_name)
  #  end

  def eventbox(name, severity)
    content_tag(:span, link_to(severity[:count], "/fault/events?event_con[severity_level]=#{name}", :class => "event-severity-#{name} #{controlled("fault/events/index")}"), :id => "eventbox-#{name}", :class => "eventbox")
  end

  def customized_menus
    menus = CustomizedMenu.all
    menu_html = []
    menus.each do |menu|
#      menu_html << content_tag(:li, link_to(menu.menu_name, {}, :onclick => "javascript:window.open('#{menu.url}'); return false;"))
    end
    menu_html.join("")
  end

  def avail_sym(s)
    return 'ping_ok' if s == "OK"
    return 'ping_critical' if s == "CRITICAL"
    #    return 'ping_warning' if s == "PING WARNING"
    #    return 'snmp_ok' if s == "SNMP OK"
    #    return 'snmp_problem' if s == "SNMP CRITICAL"
    return 'unknown'
  end

  def span_to(*args)
    content_tag(:span, link_to_unless_current(*args))
  end

  def new_window
    ['',"scrollbars=1,width=1000,height=550,screenX=150,screenY=60,location=0,directories=no,status=no,menubar=no,toolbar=no,resizable=no"]
  end

  def total_show obj
    if obj.total_entries == 0
      "显示#{obj.total_entries}个结果中的#{obj.total_entries}个"
    else
      "显示#{obj.total_entries}个结果中的#{obj.current_page == obj.page_count ? (obj.total_entries - obj.per_page * (obj.page_count - 1)) : obj.per_page}个"
    end
  end

  def bottom_show obj, type=nil
    content = nil
    if !obj.nil? && obj.length > 0
      content = (content_tag :div, total_show(obj), :class => "left f4") + (will_paginate(obj).nil? ? " " : will_paginate(obj))
    elsif !obj.nil? && obj.total_entries != 0 && type == "report" #报表
      paginate = (obj.nil? ? " " : will_paginate(obj, :renderer => "WillPaginate::LinkRenderer2"))
      content = (content_tag :div, total_show(obj), :class => "left f4") + (paginate.nil? ? "" : paginate)
    else
      content = ""
    end
    content_tag :div, content,:class =>"clearfix",:style => "margin-top:0.5em;"
  end

  def amcharts_tag(type, size, data, settings, options = {})
    defauts = {
      :width => "400",
      :height             => "300",
      :swf_path           => "/amcharts",
      :flash_version      => "8",
      :background_color   => "#FFFFFF",
      :preloader_color    => "#FFFFFF",
      :express_install    => true,
      :id                 => "amcharts#{[].object_id}",
      :help               => "To see this page properly, you need to upgrade your Flash Player",
      :size => size
    }
    if settings.is_a? Hash
      defauts[:settings_file] = url_for(settings)
    else
      defauts[:chart_settings] = settings.gsub(/\s*\n\s*|<!--.*?-->/, "").gsub(/>\s+</,"><").gsub("'","\\'") unless settings.blank?
    end
    if data.is_a? Hash
      defauts[:data_file] = url_for(data)
    else
      unless data.blank?
        defauts[:chart_data] = data.gsub(/\s*\n\s*/, "\\n").gsub("'","\\'")
      end
    end
    options = defauts.merge(options)
    if size == options.delete(:size)
      options[:width], options[:height] = size.split("x") #if size =~ %r{^\d+x\d+$}
    end

    script = "var so = new SWFObject('#{options[:swf_path]}/am#{type}.swf', " + "'swf_#{options[:id]}', '#{options[:width]}', '#{options[:height]}', " + "'#{options[:flash_version]}', '#{options[:background_color]}');"
    script << "so.addParam('wmode','opaque');so.addVariable('path', '#{options[:swf_path]}/');"
    script << "so.useExpressInstall('#{options[:swf_path]}/expressinstall.swf');" if options[:express_install]
    script << add_variable(options, :settings_file)
    script << add_variable(options, :chart_settings)
    script << add_variable(options, :additional_chart_settings)
    script << add_variable(options, :data_file)
    script << add_variable(options, :chart_data)
    script << add_variable(options, :preloader_color)
    #  script << add_swf_params(options, :swf_params)
    script << "so.write('#{options[:id]}');"
    content_tag('div', options[:help], :id => options[:id]) + javascript_tag(script)
  end

  private
  # Add variable to swfobject
  def add_variable(options, key, escape=true)
    return "" unless options[key]
    stresc = options[key]
    val = escape ? "encodeURIComponent('#{stresc}')" : "'#{stresc}'"
    "so.addVariable('#{key}', #{val});"
  end
end
