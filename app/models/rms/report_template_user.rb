class Rms::ReportTemplateUser < External
  set_sequence_name "wlan_seq_config"
  set_table_name "WLAN_RMS_TEMPLATE_USERS"

  belongs_to :report_template, :class_name => "Rms::ReportTemplate"
end
