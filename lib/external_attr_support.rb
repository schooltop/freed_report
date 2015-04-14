# To change this template, choose Tools | Templates
# and open the template in the editor.

module ExternalAttrSupport

  def self.included(base)
    base.send :include, InstanceMethods
  end

  class ExportExternalAttr < String
    attr_accessor :field
    def initialize(field)
      super field.field_name
      @field = field
    end

    def field_value(object)
      @field.display_value(object)
    end
  end

  module InstanceMethods
    def extrace_fields_group(fields)
      fields_groups = {}
      fields.each do |field|
        fields_groups[field.field_group] = [] if fields_groups[field.field_group].nil?
        fields_groups[field.field_group] << field
      end
      fields_groups
    end

    def edit_fields(field, form)
      if field.dic_codeable?
        form.select field.field_name, [["",""]] + field.options
      elsif field.enumable?
        form.select field.field_name, field.enum_field_options
      else
        form.text_field(field.field_name.to_sym)
      end
    end
    
    def external_attrs_at_export(clazz)
      ExternalAttr.displayed_fields(clazz, :field_show_in_export).collect { |field| ExportExternalAttr.new(field) }
    end

    def external_attrs_at_edit(clazz, form)
      html_content = ""
      edit_fields = ExternalAttr.displayed_fields(clazz, :field_show_in_edit)
      field_groups = extrace_fields_group(edit_fields)
      field_groups.each_pair do |group_name, fields|
        html_content << '<fieldset class="ui-widget-content ui-corner-all" style="padding-bottom: 1em; padding-left: 1em; padding-right: 1em; padding-top: 1em;"">'
        html_content << "<legend>#{group_name}</legend>"
        html_content << '<div class="wrap">'
        (0..(fields.length - 1)).step(2) do |i|
          html_content << '<div class="li">'
          html_content << '<div class="col left">'
          html_content << form.label(fields[i].field_name.to_sym, nil, :class => 'label')
          html_content << edit_fields(fields[i], form)
          html_content << '</div>'
          if i < fields.length - 1
            html_content << '<div class="col right">'
            html_content << form.label(fields[i + 1].field_name.to_sym, nil, :class => 'label')
            html_content << edit_fields(fields[i + 1], form)
            html_content << '</div>'
          end
          html_content << '</div>'
        end
        html_content << '</div>'
        html_content << "</fieldset>"
      end
      html_content
    end
  end
end

ActionView::Base.send(:include, ExternalAttrSupport::InstanceMethods)
