class Rms::WlanHnRadiusBusinessDev < External
  set_sequence_name "wlan_seq_infos"
  set_table_name "auth_hn_radius_business_dev"

  def self.delete_data(date)
    connection.execute("delete from auth_hn_radius_business_dev
      where (sampledate = to_date('#{date}','yyyy-mm-dd'))")
  end
end
