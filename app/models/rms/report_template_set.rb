class Rms::ReportTemplateSet < External
  before_save :adjust_attributes
  set_table_name "WLAN_RMS_CHART_SET"
  belongs_to :report_template, :class_name => "Rms::ReportTemplate", :foreign_key => "template_id"
  def to_json(options = {})
    super(options)
  end

  class << self
    def adjust_attributes(chart_attrs)
      chart_attrs[:group_col] = chart_attrs[:group_col].join(",") unless chart_attrs[:group_col].nil?
      chart_attrs
    end
  end
end
