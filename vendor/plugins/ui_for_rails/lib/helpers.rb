require 'ui_builder'
require 'openssl'
require 'base64'
module UI
  module Helpers
    def self.included(base)
      #base.alias_method_chain :stylesheet_link_tag, :min
      #base.alias_method_chain :javascript_include_tag, :min
    end

    #pipe 行内垂直分割线
    #example:
    #<%=pipe%>
    #=>
    #<span class="pipe">|</span>
    def pipe content="|",html_options ={}
      content_tag(:span, content,{:class =>"pipe"}.update(html_options))
    end
    #export_to 到处按钮
    #example:
    #<%= export_to 'csv', "CSV", {:controller=>'perf_reports',:action=>'export_csv'} %>
    #=>
    #<a class="csv-export-format" href="/report/perf_reports/export_csv.csv"><em class="icon icon-csv"/>CSV</a>

    def export_to(format, text, url_options, html_options = {})
      #link_to_unless_current(icon(format) + text, url_options.merge({:format => format}), :class => "#{format}-export-format")
      link_to_unless_current("<img title='保存为Excel文件' src='/images/export_csv.png'>", url_options.merge({:format => format}), {:class => "#{format}-export-format"}.update(html_options))
    end

    def link_button_to(*args)
      name         = args.first
      options      = args.second || {}
      html_options = args.third
      confirm = options.delete :confirm if options.is_a? Hash
      url = args.fourth
      url ||= url_for(options)
      if html_options
        html_options = html_options.stringify_keys
        convert_options_to_javascript!(html_options, url)
      else
        html_options = {}
      end
      confirm = confirm.blank? ? "":"if(window.confirm('#{confirm}'))"
      html_options["onclick"] ||=  "javascript:#{confirm}document.location.href='#{url}'; return false;"
      html_options.merge!("type" => "button", "value" => name)
      tag("input", html_options)
    end
    
    def header_title text = nil, options = {}, &block
      if block_given?
        options = text || {}
        options[:class] ||= 'header-title'
        concat tag('h1',options,true)
        concat icon(options.delete(:icon) || 'h-t')
        concat capture(&block)
        concat '</h1>'
      else
        text = icon(options.delete(:icon) || 'h-t') + text
        options[:class] ||= 'header-title'
        content_tag :h1, text ,options
      end
    end
    def truncate_tag text, length = 30, omission = "..."
      text ||= ""
      if text.size > length
        text = content_tag(:span, truncate(text,:length => length, :omission => omission), :title => text)
      end
      text
    end

    #ui_visual is not used
    def ui_visual grid,options ={}
      id = "visual_"+grid.grid_id.to_s
      options = {:type =>'Table'}.update(options)
      options[:data] = {}
      options[:data][:column] = grid.column_names
      options[:data][:data] = grid.data_array
      content_for :head,javascript_tag("google.setOnLoadCallback(function(){$(\"##{id}\").visual(#{options.to_json});});")
      content = content_tag "div","",:id => id,:class => "ui-visual"
    end

    def board content_or_options_with_block = nil,options =nil,&block
      content_tag_with_default_class("div","board ui-widget",content_or_options_with_block,options,&block)
    end

    def board_header content_or_options_with_block = nil,options =nil,&block
      content_tag_with_default_class("h4","board-header ui-widget-header ui-corner-top",content_or_options_with_block,options,&block)
    end

    def board_content content_or_options_with_block = nil,options =nil,&block
      content_tag_with_default_class("div","board-content ui-widget-content ui-corner-bottom",content_or_options_with_block,options,&block)
    end

    def ui_grid options={},&block
      raise ArgumentError, "Missing block" unless block_given?
      options[:cellSpacing] ||= 0
      options[:class] ||=''
      options[:class] << ' ui-grid ui-widget ui-widget-content ui-corner-all ui-helper-reset'
      if options[:scrollable]
        options[:class] ||= ''
        options[:class] << ' ui-grid-scrollable'
        concat(tag('div',options.merge(:scrollable =>nil),true))
      else
        concat(tag('table',options,true))
      end
      builder = options[:builder] || UI::Builder::Grid
      yield builder.new(options,self,nil,block)
      if options[:scrollable]
        concat('</div>')
      else
        concat('</table>')
      end
    end
    def ui_grid_for object, options={},&block
      raise ArgumentError, "Missing block" unless block_given?
      options[:cellSpacing] ||= 0
      options[:class] ||=' '
      options[:class] << ' ui-grid ui-widget ui-widget-content ui-corner-all ui-helper-reset'
      options[:id] ||= "grid_" + object.grid_id
      if options[:scrollable]
        options[:class] ||= ''
        options[:class] << ' ui-grid-scrollable'
        concat(tag('div',options.merge(:scrollable =>nil),true))
      else
        concat(tag('table',options,true))
      end
      builder = options[:builder] || UI::Builder::Grid
      yield builder.new(options,self,object,block),object.columns,object.data
      if options[:scrollable]
        concat('</div>')
      else
        concat('</table>')
      end
    end

    def license(license_suffix)
      filename = "#{RAILS_ROOT}/LICENSE.#{license_suffix}"
      license = ""
      f = File.open(filename, "r")
      f.each_line do |line|
        license += line
      end
      return license
    end

    def decode_license(key, str)
      str = Base64.decode64(str)
      des = OpenSSL::Cipher::Cipher.new("DES-EDE3-CBC")
      des.pkcs5_keyivgen(key, "opengoss")
      des.decrypt
      des.update(str) + des.final
    end

    def permits
      domain = current_user.domain.base.split(",")
      license_suffix = domain[domain.length - 2].split("=")[1]
      domain = domain[domain.length - 2] + "," + domain[domain.length - 1]
      license_content = license(license_suffix)
      permits = []
      begin
        unless license_content.empty?
          permits = decode_license(domain, license_content).split(",")
        end
      rescue Exception =>e
      end
      return permits
    end

    def ui_menubar options={},&block
      raise ArgumentError, "Missing block" unless block_given?
      options[:class] ||=''
      options[:class] << ' ui-menu ui-widget ui-helper-reset'
      concat(tag('ul',options,true))
      builder = options[:builder] || UI::Builder::Menu
      yield builder.new(options,self,permits,block)
      concat('</ul>')
    end

    def ui_screen object ,options={},&block
      raise ArgumentError, "Missing block" unless block_given?
      options[:class] ||= ''
      options[:class] << ' ui-screen'
      concat(tag('div',options,true))
      builder = options[:builder] || UI::Builder::Grid
      yield builder.new(options,self,object,block),object.columns
      concat('</div>')
    end

    def partial_exist? directory,name,options={}
      file = File.join(view_paths.first, directory,'_' + name)
      File.exist?(file+'.html.erb') || File.exist?(file+'.erb')
    end

    def ui_error msg,options = {}
      return '' if msg.nil?
      options[:class] ||= ''
      options[:class] << ' ui-state-error ui-widget ui-corner-all error clearfix'
      title = options.delete(:title)
      title = title.nil? ? '' : content_tag(:strong,title)
      content_tag(:div,link_to(ui_icon('close'),'#',:class => 'right',:title => '关闭',:onclick =>'$(this).parents(\'.error\').slideUp();return false;')+ui_icon('alert')+title+msg,options)
    end

    def ui_highlight msg,options = {}
      return '' if msg.nil?
      options[:class] ||= ''
      options[:id] ||= "windowtips"
      options[:class] << ' ui-state-highlight ui-widget ui-corner-all highlight clearfix'
      title = options.delete(:title)
      title = title.nil? ? '' : content_tag(:strong,title)
      content_tag(:div,link_to(ui_icon('close'),'#',:class => 'right',:title => '关闭',:onclick =>'$(this).parents(\'.highlight\').slideUp();return false;')+ui_icon('info')+title+msg,options)
    end

    def ui_icon class_name,options = {}
      options[:class] = 'ui-icon ui-icon-'+class_name
      options[:title] = "不可编辑"    if class_name.blank?
      content_tag(:em,options[:title],options)
    end

    def icon class_name,options = {}
      options[:class] = 'icon icon-'+class_name
      content_tag(:em,options[:title],options)
    end
    
    def li_to(name, options = {}, html_options = {}, &block)
      current_class = html_options.delete :current_class
      current_class ||= 'current ui-state-default'
      user_defined_menu = html_options[:id]
      current_menu = user_defined_menu
      current_menu ||= options[:current_menu]
      current_menu ||= options[:action].nil? ? 'index' : options[:action]
      menu = controller.submenu_item
      if menu.is_a? Symbol
        current = (!params[menu].nil?  and params[menu].to_s == options[menu].to_s)
      elsif menu.is_a? Array
        current = true
        menu.each do |m|
          current = false if params[m].to_s != options[m].to_s
        end
      else
        current = menu == current_menu
      end
      class_name = ((user_defined_menu || controller.controller_name == options[:controller]) && current) ? current_class : ''
      if options[:class]
        class_name += ' '+options[:class]
        options.delete :class
      end
      class_name = nil if class_name ==''
      content_tag(:li,link_to(name,options,html_options,&block),:class=>class_name)
    end

    #select navigation
    def menu_item_to id,name,options={},html_options={:class=>''},&block
      html_options[:id] = id
      class_name = nil
      if(controller.menu_item == id)
        class_name = 'ui-corner-top ui-state-active'
      end
      content_tag(:li,link_to(name,options,html_options,&block),:class=>class_name)
    end
    
    def submenu_item_to  name,options={},html_options={},&block
      #name=content_tag(:em,'close',:class=>'ui-icon ui-icon-close',:onclick=>'return false;')+name
      #html_options = {:current_class => 'current ui-state-default' }.update(html_options)
      li_to name,options,html_options,&block
    end

    def stylesheet_link_tag_with_min *sources
      sources.collect! do |source|
        if RAILS_ENV.include?(min_env) and source.is_a?(String) and source[0,2]=='ui'
          'min/' + source
        else
          source
        end
      end
      stylesheet_link_tag_without_min *sources
    end
    def javascript_include_tag_with_min *sources
      sources.collect! do |source|
        if RAILS_ENV.include?(min_env) and source.is_a?(String) and source[0,2]=='ui'
          'min/' + source
        else
          source
        end
      end
      javascript_include_tag_without_min *sources
    end

    private
    def add_class_to_options class_name,options=nil
      options ||={}
      options[:class] ||=""
      options[:class] << " "+class_name
      options
    end

    def content_tag_with_default_class tag,default_class_name,content_or_options_with_block = nil,options =nil,&block
      if block_given?
        content_or_options_with_block = add_class_to_options(default_class_name,content_or_options_with_block)
      else
        options = add_class_to_options(default_class_name,options)
      end
      content_tag(tag,content_or_options_with_block,options,&block)
    end
    def min_env
      'production'
    end
  end
end

module ActionView
  module Helpers
    module TagHelper
      #给标签添加默认主题样式
      #当options中:class属性第一个字母不是空格的时候不添加样式。
      #例子:
      #tag(:input,:type=>"text") => <input class="text ui-input" type="text" />
      #tag(:input,:type=>"text",:class=>" q") => <input class="text ui-input q" type="text" />
      #tag(:input,:type=>"text",:class=>"q") => <input class="q" type="text" />
      #
      #规则：
      #input 标签 默认class为type值
      #select 默认class=>'select ui-input'
      #
      def css_options_for_tag(name, options={})
        name = name.to_sym
        options = options.stringify_keys
        class_name = (options.has_key? 'class') && (!options['class'].nil?) && (options['class'].is_a?(String))

        if class_name and (options['class'][0]!=32)
          return options

        else


          class_name = class_name ? options['class']:''
          if name == :select
            options['class'] = "select ui-input"
            options['class'] << class_name
            options['class'] << " ui-state-disabled" if options["disabled"].eql?"disabled" or options["disabled"] === true
          end
          if name == :input and options['type']
            return options if (options['type'] == 'hidden')

            options['class'] = options['type'].dup
            options['class'] << ' ui-corner-all ui-state-default' if ['submit', 'reset','button'].include? options['type']
            options['class'] << ' button' if ['reset'].include? options['type']
            options['class'] << ' ui-input text' if options['type'] == 'password'
            options['class'] << ' ui-input' if options['type'] == 'text'
            options['class'] << class_name
          elsif name == :textarea
            options['class'] = 'ui-input textarea'
            options['class'] << class_name
          end
          options['class'] << " ui-state-disabled" if options["disabled"].eql?"disabled" or options["disabled"] === true
          options
        end
      end

      def tag_with_css(name, options=nil, open=false, escape=true)
        tag_without_css(name, css_options_for_tag(name, options || {}), open, escape)
      end
      alias_method_chain :tag, :css

      def content_tag_string_with_css(name, content, options, escape=true)
        content_tag_string_without_css(name, content, css_options_for_tag(name, options || {}), escape)
      end
      alias_method_chain :content_tag_string, :css
    end

    class InstanceTag
      alias_method :tag_without_error_wrapping, :tag_with_css
    end
    class FormBuilder
      #Transforms label content
      def label_with_human(method, text = nil, options = {})

        text = text.nil? ? @object.class.human_attribute_name(method.to_s):text
        options[:class] ||=""
        options[:class] << " label"
        text << "："
        text = "<em>*</em>" + text if options.delete(:required)

        label_without_human(method, text, options)
      end
      alias_method_chain :label, :human
      #automatic recognize tag follow the data type
      #:string, :text, :integer, :float, :decimal, :datetime,
      #:timestamp, :time, :date, :binary, :boolean
      #
      #:string, :text, :integer, :float,  :datetime,
      #:datetime, :time, :date, :binary
      def auto_tag_for(name,*args)

        type = @object.column_for_type(name)

        field_type = case type
        when :integer, :float, :decimal   then :text_field
        when :datetime, :timestamp        then :datetime_select
        when :time                        then :time_select
        when :date                        then :date_select
        when :string                      then :text_field
        when :text                        then :text_area
        when :boolean                     then :check_box
        else
          :text_field
        end
        helper = method(field_type)
        helper.call(name,*args)

      end
    end
  end
end
