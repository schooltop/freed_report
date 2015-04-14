class UltReport::ReportTemplateUser < External
  set_sequence_name "wlan_seq_config"
  set_table_name "ULTRA_PRO_PERF_TEMPLATE_USERS"

  belongs_to :report_template, :class_name => "UltReport::ReportTemplate"
end
