class Rms::WlanPortPerfAggr < External
  set_table_name "wlan_port_perf_aggr"
  set_sequence_name "wlan_seq_infos"

  class << self
    def get_port_perf_aggr_hourly(date,filter_type)
      find_by_sql("select t2.citycn,t2.towncn,t2.portcn,t3.code_name porttype,
      t4.remark sub_port_type,t2.address,t1.sampledate,t1.samplehour,t1.busy_apnum,
      decode(t1.pingall_count,0,0,t1.pingok_count/t1.pingall_count) ap_avail,
      t1.deauthnum,t1.assocsuccnum,t1.reassocsuccnum,t1.assocnum,t1.reassocnum,
      (t1.assocsuccnum + t1.reassocsuccnum + 0.00001)/(t1.assocnum + t1.reassocnum + 0.00001) accocsucc_rate,
      t1.deauthnum/(t1.assocsuccnum + t1.reassocsuccnum + 0.00001) off_line_rate
      from wlan_port_perf_aggr t1,device_infos t2,
      dic_codes t3,dic_codes t4
      where t1.sampledate = to_date('#{date}','yyyy-mm-dd')
      and t1.#{filter_type} = 1
      and t1.port = t2.id(+)
      and t2.port_type = t3.id(+)
      and t1.sub_type = t4.id(+)")
    end
  end
end
