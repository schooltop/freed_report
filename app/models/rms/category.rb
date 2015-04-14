class Rms::Category < External
  set_sequence_name "wlan_seq_config"
  set_table_name "WLAN_RMS_TEMPLATE_CATEGORY"
  has_many :templates, :class_name => "Rms::ReportTemplate", :foreign_key => "category_id"
  has_many :template_groups, :select => "distinct(netloc_gran) t_group, category_id",
           :class_name => "Rms::ReportTemplate", :foreign_key => "category_id", :order => "netloc_gran ASC"
  
  def find_templates_by_group(netloc_gran)
    Rms::ReportTemplate.all :conditions => {:category_id => id, :netloc_gran => netloc_gran,  :group_type => 2}
  end
end

