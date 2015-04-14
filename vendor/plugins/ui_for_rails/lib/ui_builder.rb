module UI
  module Builder
    class Grid
      def initialize(options,template,object,proc)
        @options,@template,@object,@proc =options,template,object, proc
        @mark = nil
        @odd = false
        @column_num = 0
        @column_data_num = 0
        @class_names = []
        @cache_width = []
        @head_cache = ""
      end
      def scrollable? 
        @options[:scrollable]
      end
      def head options={},&block
        raise ArgumentError, "Missing block" unless block_given?
        @mark = :head
        if scrollable?
          concat tag('div',{:class =>'ui-grid-scroll-head'},true)
          concat tag('table',{:cellSpacing => 0},true)
        end
        head_c = ""
        head_c << tag('thead',options,true)
        head_c << @template.capture(&block)
        head_c << '</thead>'
        @head_cache = head_c
        concat head_c
        if scrollable?
          concat '</table></div>'
        end
      end
      def body options={},&block
        raise ArgumentError, "Missing block" unless block_given?
        @mark = :body
        #concat content_tag('tfoot',content_tag('tr',content_tag('th','<div><p><span style="width:'+(@column_num*100/@display_num).to_s+'%;">scrollbar</span></p></div>',:colspan =>@column_num),:class=>'ui-grid-scrollbar'))
        if scrollable?
          options[:class] ||=""
          options[:class] << "ui-grid-scroll-body"
          concat tag('div',options, true)
          concat tag('table',{:cellSpacing => 0},true)
          #concat @head_cache
          options = nil
        end
        concat tag('tbody',options,true)
        yield
        concat '</tbody>'
        if scrollable?
          concat '</table></div>'
        end
      end
      def r options={},&block
        raise ArgumentError, "Missing block" unless block_given?
        @column_data_num = 0
        options[:class] ||= ''
        case @mark
        when :head then options[:class] << 'ui-widget-header ui-grid-header'
        when :body 
          if @odd
            options[:class] << ' ui-grid-odd ui-state-light'
          else
            options[:class] << ' ui-grid-even'
          end
          @odd = !@odd
        else
          raise ArgumentError, "Missing head tag or body tag" unless block_given?
        end
        concat tag('tr',options,true)
        yield
        concat '</tr>'
      end
      def format_sort content='',text=nil,options ={}
        text ||= content
        if text.is_a?(Hash)
          options = text
          text = content
        end

        params = @template.controller.params
        html_options = options[:html] || {}
        _url_options = (options[:url] || params).dup
        sort = options[:sort] || params[:sort]
        if(sort.nil? || sort.empty? || sort[0]!=45)
          old_sort_dir = ""
        else
          sort = sort.slice(1,(sort.size-1))
          old_sort_dir = "-"
        end
        sort_direction_indicator = ''
        sort_dir =''
        if content.to_s == sort
          sort_dir = old_sort_dir == '-' ? '':'-'
          sort_direction_indicator = @template.ui_icon(sort_dir == "-" ? "triangle-1-n":"triangle-1-s")
        end
        @column_num = @column_num + 1
        name = content.to_s
        if content.is_a?(Symbol)
          class_name= @object.grid_id+"_"+ content.to_s
        else
          class_name = nil
        end
        if text.is_a?(Symbol)
          content = @object.human_attribute_name text
        else
          content = text
        end
        @class_names[@column_num] = class_name
        html_options[:class] ||=class_name
        content ='&nbsp;' if content.nil? or content.to_s.empty?
        content = @template.link_to(content,_url_options.update(:sort =>sort_dir+name), html_options) + sort_direction_indicator
        if scrollable? and html_options[:width]
          width = html_options[:width].to_i.to_s
          @cache_width[@column_num] = width
          content = content_tag "div",content,{:class =>"ui-grid-c",:style => "width:"+width+"px" }
        end
        content_tag('th',content,html_options)

      end
      def h content_or_options_with_block='',options={},&block
        @column_num = @column_num + 1
        if block_given?
          options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          options[:class] ||=''
          content = @template.capture(&block)
          if scrollable? and options[:width]
            width = options[:width].to_i.to_s
            @cache_width[@column_num] = width
            content = content_tag "div",content,{:class =>"ui-grid-c",:style => "width:"+width+"px" }
          end
          content = content_tag('th', content, options)
          concat(content)
        else
          content = content_or_options_with_block
          if content.is_a?(Symbol)
            class_name= @object.grid_id+"_"+ content.to_s
            content = @object.human_attribute_name content
          else
            class_name = nil
          end
          @class_names[@column_num] = class_name
          options[:class] ||=class_name
          content ='&nbsp;' if content.nil? or content.to_s.empty?
          if scrollable? and options[:width]
            width = options[:width].to_i.to_s
            @cache_width[@column_num] = width
            content = content_tag "div",content,{:class =>"ui-grid-c",:style => "width:"+width + "px" }
          end
          content_tag('th',content,options)
        end
      end
      def d content_or_options_with_block='',options={},&block
        @column_data_num = @column_data_num + 1
        if block_given?
          options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          options[:class] ||=@class_names[@column_data_num]
          content = @template.capture(&block)
          if scrollable? 
            width = @cache_width[@column_data_num]
            if width
              content = content_tag "div",content,{:class =>"ui-grid-c",:style => "width:"+width+"px" }
            end
          end
          content = content_tag('td',content, options)
          concat(content)
        else
          content = content_or_options_with_block
          options[:class] ||=@class_names[@column_data_num]
          content ='&nbsp;' if content.nil? or content.to_s.empty?
          if scrollable? 
            width = @cache_width[@column_data_num]
            if width
              content = content_tag "div",content,{:class =>"ui-grid-c",:style => "width:"+width+"px" }
            end
          end
          content_tag('td',content,options)
        end
      end

      def c content='',text=nil,options ={}
        text ||= content
        if text.is_a?(Hash)
          options = text
          text = content
        end
        class_id = @object.grid_id
        if content.is_a?(Symbol)
          class_name= class_id+"_"+ content.to_s
        else
          class_name = ''
        end
        options[:class] ||= ''
        options[:class] << ' '+class_name
        if text.is_a?(Symbol)
          content = @object.human_attribute_name text
        else
          content = text
        end
        @template.label_tag(class_name,content,options) + @template.check_box_tag(class_id+"[#{text.to_s}]",'',true,{:id=> class_name})
      end
      private
      def customize_options type
        case type
        when :select
          {:class =>'ui-grid-select ui-grid-fixed'}
        when :actions
          {:class =>'ui-grid-actions ui-grid-fixed'}
        else
          {}
        end
      end
      def tag *args
        @template.send(:tag,*args)
      end
      def concat *args
        @template.send(:concat,*args)
      end
      def content_tag *args
        @template.send(:content_tag,*args)
      end
    end
    
    class Menu
      def initialize(options,template,permits,proc)
        @options,@template,@permits,@proc =options, template, permits, proc
        @mark, @items, @menu_id = nil, [], 1
      end

      def menu content,options={},html_options={},&block
        raise ArgumentError, "Missing block" unless block_given?
        options[:class] ||= ''
        options[:class] << 'ui-menu-content ui-helper-reset ui-widget-content ui-corner-bottom'
        item("menu_#{@menu_id}", content) do
          concat tag('ol',options,true)
          yield
          concat '</ol>'
        end
        if @items.empty? && not_webgis?
          concat "<style type='text/css'>"
          concat "#menu_#{@menu_id} {display: block;}"
          concat "</style>"
        end
        # items & menu_id used for configure menu
        @items = []
        @menu_id += 1
      end

      def item id, content='', options={}, html_options={}, &block        
        if block_given?
          html_options[:class] ||= ''
          html_options[:id] = id
          if html_options.delete(:open) === false
            icon = 'carat-1-s'
            class_name = 'ui-menu-header ui-helper-reset ui-state-default ui-corner-all'
          else
            html_options[:class] << 'ui-menu-open'
            icon = 'carat-1-n'
            class_name = 'ui-menu-header ui-helper-reset ui-widget-header ui-corner-top'
          end
          c = tag('li',html_options,true)
          c << content_tag('h3',@template.ui_icon(icon)+@template.link_to(content,'#'),:class =>class_name)
          concat(c)
          yield
          concat('</li>')
        else
          if (@permits.include?(id) && !id.blank?) || @template.request.path.start_with?("/admin") || @template.request.path.start_with?("/report/cmcc_reports") || @template.request.path.start_with?("/personal")
            @items << id
            html_options[:id] = id
            @template.submenu_item_to(content,options,html_options)
          end
        end
      end

      def tag *args
        @template.send(:tag,*args)
      end

      def concat *args
        @template.send(:concat,*args)
      end

      def content_tag *args
        @template.send(:content_tag,*args)
      end

      private
      def not_webgis?
        !webgis? 
      end

      def webgis?
        @template.request.path.start_with?("/webgis") 
      end
    end

  end
end
