class Rms::WlanPortPerfAggrDay < External
  set_table_name "wlan_port_perf_aggr_day"
  set_sequence_name "wlan_seq_infos"
  class << self
    def get_port_perf_aggr_day(date,filter_type)
      find_by_sql("select t2.citycn,t2.towncn,t2.portcn,t3.code_name porttype,
      t4.remark sub_port_type,t2.address,t1.sampledate,t1.busy_apnum,
      decode(t1.pingall_count,0,0,t1.pingok_count/t1.pingall_count) ap_avail,
      t1.deauthnum,t1.assocsuccnum,t1.reassocsuccnum,t1.assocnum,t1.reassocnum,
      (t1.assocsuccnum + t1.reassocsuccnum + 0.00001)/(t1.assocnum + t1.reassocnum + 0.00001) accocsucc_rate,
      t1.deauthnum/(t1.assocsuccnum + t1.reassocsuccnum + 0.00001) off_line_rate
      from wlan_port_perf_aggr_day t1,device_infos t2,
      dic_codes t3,dic_codes t4
      where t1.sampledate = to_date('#{date}','yyyy-mm-dd')
      and t1.#{filter_type} = 1
      and t1.port = t2.id(+)
      and t2.port_type = t3.id(+)
      and t1.sub_type = t4.id(+)")
    end

    def get_port_by_offline_rate
      date = (Time.now - 1.days).strftime("%Y-%m-%d")
      date2 = (Time.now - 7.days).strftime("%Y-%m-%d")
      find_by_sql("select nodedn from (
      select t1.sampledate,t2.nodedn,
      decode(sum(pingall_count),null,1,0,1,sum(pingall_count-pingok_count)/sum(pingall_count)) offline_rate
      from wlan_port_perf_aggr_day t1,device_infos t2
      where t1.port = t2.id
      and t1.project_state  = 1
      and t1.sampledate >= to_date('#{date2}','yyyy-mm-dd')
      and t1.sampledate <= to_date('#{date}','yyyy-mm-dd')
      group by t1.sampledate,t2.nodedn)
      where offline_rate < 0.03
      group by nodedn
      having count(*) >= 7")
    end

    def get_port_by_bytes_sta
      date = (Time.now - 1.days).strftime("%Y-%m-%d")
      date2 = (Time.now - 1.months).strftime("%Y-%m-%d")
      find_by_sql("select nodedn from (
      select t2.nodedn
      from wlan_port_perf_aggr_day t1,device_infos t2
      where t1.port = t2.id(+)
      and t1.project_state  = 1
      and t1.sampledate >= to_date('#{date2}','yyyy-mm-dd')
      and t1.sampledate <= to_date('#{date}','yyyy-mm-dd')
      group by t2.nodedn having sum(rxbytestotal+txbytestotal)/1000 > 6
      union
      select t2.nodedn
      from wlan_wifi_port_aggr_day t1,device_infos t2
      where t1.port = t2.id(+)
      and t1.project_state  = 1
      and t1.sampledate >= to_date('#{date2}','yyyy-mm-dd')
      and t1.sampledate <= to_date('#{date}','yyyy-mm-dd')
      group by t2.nodedn having max(sta_num) > 10
      )")
    end

  end
end
