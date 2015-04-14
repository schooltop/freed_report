class Rms::WlanHnRadiusImport < External
  set_sequence_name "wlan_seq_infos"
  set_table_name "auth_hn_radius_import"

  def self.truncate_table
    connection.execute("truncate table auth_hn_radius_import")
  end
end
