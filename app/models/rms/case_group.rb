class Rms::CaseGroup < External
  set_sequence_name "wlan_seq_config"
  set_table_name "WLAN_CASE_GROUPS"
  validates_presence_of :case_name, :message => "专案名称不能为空！"

  def self.get_special_name
    Rms::CaseGroup.find_by_sql("select id,case_name from wlan_case_groups
      where id in (select case_id from wlan_case_aps)")
  end
end
