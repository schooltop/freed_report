class Rms::WlanHnRadiusTimeTraffic < External
  set_sequence_name "wlan_seq_infos"
  set_table_name "auth_hn_radius_time_traffic"

  def self.delete_data(date)
    connection.execute("delete from auth_hn_radius_time_traffic
      where (sampledate = to_date('#{date}','yyyy-mm-dd'))")
  end
end
