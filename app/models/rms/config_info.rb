module Rms
  class ConfigInfo  < External
    set_table_name "config_infos_temp"
    set_sequence_name "wlan_seq_infos"
    
    def self.truncate_all
      connection.execute("truncate table config_infos_temp")
    end

    def self.all_count
      all_num = ConfigInfo.find_by_sql("select count(*) num from config_infos_temp
        where nodetype in (0,1,2,3,4,5,6,7,8,9,11)")
      all_counts = all_num[0].num.to_i
      return all_counts
    end

    def self.collect_ap_count
      all_num = ConfigInfo.find_by_sql("select count(*) num from config_infos_temp
        where nodetype = 11 and device_state = 0")
      all_counts = all_num[0].num.to_i
      return all_counts
    end

  end
end