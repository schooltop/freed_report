class Rms::WlanAuthStatusAcAggr < External
  set_sequence_name "wlan_seq_infos"
  set_table_name "auth_auth_status_ac_aggr"

  def self.delete_data(date)
    last_date = (date.to_date-1.day).strftime('%Y-%m-%d')
    connection.execute("delete from auth_auth_status_ac_aggr
      where (sampledate = to_date('#{date}','yyyy-mm-dd') and samplehour < 24)
      or (sampledate = to_date('#{last_date}','yyyy-mm-dd') and samplehour = 24)")
  end
end
