class Rms::CaseAp <  External
  set_sequence_name "wlan_seq_config"
  set_table_name "WLAN_CASE_APS"

  def self.get_special_aps(case_id)
    Rms::CaseAp.find_by_sql("select t1.id,t2.nodecn,t2.nodedn from wlan_case_aps t1,device_infos t2
      where t1.ap = t2.id
      and t1.case_id = #{case_id}")
  end
end
