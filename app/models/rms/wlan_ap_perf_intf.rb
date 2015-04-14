class Rms::WlanApPerfIntf < External
  set_sequence_name "wlan_seq_infos"
  set_table_name "WLAN_AP_PERF_INTF"

  def self.truncate_table
    connection.execute("truncate table wlan_ap_perf_intf")
  end
end
