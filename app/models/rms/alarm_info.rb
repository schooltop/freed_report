class Rms::AlarmInfo < External
  set_table_name "wlan_alarm_aggr_temp"
  set_sequence_name "wlan_seq_infos"

  def self.truncate_all
    connection.execute("truncate table wlan_alarm_aggr_temp")
  end
end
