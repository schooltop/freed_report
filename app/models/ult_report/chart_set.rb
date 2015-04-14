class UltReport::ChartSet < External
  set_sequence_name "wlan_seq_config"
  set_table_name "ULTRA_PRO_PERF_CHART_SET"
  
  belongs_to :template ,:class_name=>'UltReport::ReportTemplate',:foreign_key =>'template_id'
  
  def before_save
      return false unless self.x_col && !self.x_col.empty? && self.chart_type
  end

end
