require "csv"
require "rubygems"
require "fastercsv"
module UI
  class Grid
    attr_reader :data, :data_array, :columns, :columns_hash, :column_names
    @@num = 0
    def initialize(columns_or_model,data)
      @columns_or_model = columns_or_model
      @data = data
      if is_model?
        @columns = @columns_or_model.columns.map {|column| {:name =>column.name,:type =>column.type}}
      elsif @columns_or_model.is_a?(Array)
        begin
          @columns_or_model.pop if @columns_or_model.last.name=="R" #去掉R
        rescue Exception
          " "
        end
        @columns = @columns_or_model.map {|column|
          if column and (column["name"] || column[:name])
            column = column["name"] || column[:name]
          end
          {:name =>column,:type =>nil}
        }
      else
        raise ArgumentError, "columns is invalid!"
      end
      @columns_hash = @columns.inject({}) { |hash, column| hash[column[:name]] = column; hash }
      @column_names = @columns.map{ |column| column[:name] }
    end

    def human_attribute_name attr_key,options ={}
      attr_key = attr_key.to_s
      if is_model?
        @columns_or_model.human_attribute_name attr_key
      else
        attr_key 
      end
    end

    def grid_id
      if is_model?
        ::ActionController::RecordIdentifier.singular_class_name(@columns_or_model)
      else
        @@num = @@num +1
        "g"+@@num.to_s
      end
    end

    def is_model?
      @columns_or_model.is_a?(Class)
    end

    def to_xml
      @data.to_xml
    end

    def to_csv_file(file_path, column_names=nil, human_attr=true, &block)
      to_text_file(file_path, column_names, human_attr, &block) 
    end

    def to_csv(column_names=nil, human_attr=true, &block)
      # to_text(column_names, ',', human_attr, &block)
      to_text_use_fastcsv(column_names, human_attr, &block)
    end

    def to_tsv(column_names=nil, human_attr=true, &block)
      to_text(column_names, '\t', human_attr, &block)
    end

    protected
      def to_text_file(file_path, column_names, human_attr, &block)
        File.open(file_path, 'w') do |file|
          file << to_text_use_fastcsv(column_names, human_attr, &block)
        end
      end

      def to_text_use_fastcsv(column_names, human_attr, &block)
        column_names = column_names || @column_names
        export_csv_str = FasterCSV.generate do |csv|
          # header
          csv << column_names.map do |col|
            begin
              (human_attr ? human_attribute_name(col) : col)
            rescue
              col
            end
          end
          # lines
          @data.each do |data|
            csv << column_names.map do |col|
              csv_data = (block_given? ? yield(col, data) : data[col.to_sym]).to_s
            end
          end
        end
        export_csv_str.to_iso
      end

      def to_text(column_names,sep,human_attr=true,&block)
        export = StringIO.new
        column_names = column_names || @column_names
        CSV::Writer.generate(export, sep) do |csv|
          # csv header fields
          csv << column_names.collect do |c|
            begin
              (human_attr ? human_attribute_name(c) : c).to_iso
            rescue
              c.to_s
            end
          end
          # csv lines
          @data.each do |d| 
            csv << column_names.collect do |c| 
              if block_given?
                dd = yield c,d
              else
                dd = d[c.to_sym]
              end
              begin
                dd.nil? ? "" : dd.to_s.strip.gsub(/\n/, "").to_iso
              rescue
                dd.to_s
              end
            end
          end
        end
        export.rewind
        export.read
      end
  end

  module ActionController
    def self.included(base)
      base.alias_method_chain :render, :layout_extension
      class << base
        def menu_item name
          write_inheritable_attribute(:menu_item, name)
        end   

        def submenu_item name
          write_inheritable_attribute(:submenu_item, name)
        end   

        def sidebar template_name
          write_inheritable_attribute(:sidebar, template_name)
        end
      end
    end

    def title
      @title
    end

    def title=(title)
      @title = title
    end
    def theme
      @theme || "base"
    end

    def theme=(theme)
      @theme = theme
    end

    def menu_item
      n = self.class.read_inheritable_attribute(:menu_item)
      n = self.class.read_inheritable_attribute(:current_nav) if n.nil?
      n = controller_path if n.nil?
      n
    end   
    def sidebar
      n = self.class.read_inheritable_attribute(:sidebar)
      n = @sidebar_directory if n.nil?
      n = self.class.controller_path if n.nil?
      n
    end
    def submenu_item value=nil
      if value.nil?
        n = self.class.read_inheritable_attribute(:submenu_item)
        n = params[:current_menu] if n.nil?
        n = action_name if n.nil?
        n
      else
        self.class.write_inheritable_attribute(:submenu_item,value)
      end
    end
    def render_with_layout_extension(options = nil ,extra_options ={} ,&block)
      if options.is_a? Hash
        submenu_item = options.delete(:submenu_item)
        self.class.submenu_item submenu_item unless submenu_item.nil?
        menu_item = options.delete :menu_item
        self.class.menu_item menu_item unless menu_item.nil?
        sidebar = options.delete :sidebar
        self.class.sidebar sidebar unless sidebar.nil?
      end
      render_without_layout_extension options,extra_options,&block
    end

  end
  module ActiveRecord
    def self.included(base)
      class << base
        #ui display columns
        def column_display_names
          @@column_display_names ||= column_names - ['id','updated_at','created_at']
        end
        def column_display *args
          if args.size
            options = args.first
            if options.is_a?(Hash)
              except = options.delete :except
              except.map!{|x| x.to_s} unless except.nil?
              inc = options.delete :include
              inc.map!{|x| x.to_s} unless inc.nil?
              only = options.delete :only
              only.map!{|x| x.to_s} unless only.nil?

              @@column_display_names = column_display_names - except unless except.nil?
              @@column_display_names = column_display_names + inc unless inc.nil?
              @@column_display_names = only unless only.nil?
            else
              @@column_display_names = args.map!{|x| x.to_s}
            end
          end
        end
      end
    end

    # Returns the column data type for the named attribute.
    def column_for_type(name)
      column = self.class.columns_hash[name.to_s]
      type = column.type
      sql_type = column.sql_type
      %w(tinyint decimal).each do |t|
        type = t.to_sym if sql_type.include?(t)
      end
      type
      #column_for_attribute(name).instance_variable_get(:@type)
    end

  end
end
