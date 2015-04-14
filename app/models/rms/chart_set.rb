class Rms::ChartSet < External
  set_sequence_name "wlan_seq_config"
  set_table_name "WLAN_RMS_CHART_SET"
  
  belongs_to :template ,:class_name=>'Rms::ReportTemplate',:foreign_key =>'template_id'
  
  def before_save
      return false unless self.x_col && !self.x_col.empty? && self.chart_type
  end

end
