class Rms::WlanAcPerfAggr < External
  set_table_name "wlan_ac_perf_aggr"
  set_sequence_name "wlan_seq_infos"

  class << self
    def get_ac_perf_aggr_day(date)
      find_by_sql("select t2.citycn,t2.towncn,t2.nodecn,t2.ip,t2.address,
      t3.remark ac_manu,t4.remark ac_type,t1.sampledate,t1.ac,
      max(t1.ifinoctetsmax)/450000 ifin,max(t1.ifoutoctetsmax)/450000 ifout
      from wlan_ac_perf_aggr t1
      left join device_infos t2 on t1.ac = t2.id
      left join dic_codes t3 on t1.device_manu = t3.id
      left join dic_codes t4 on t1.device_type = t4.id
      where t1.sampledate = to_date('#{date}','yyyy-mm-dd')
      and (t1.ifinoctetsmax/450000 >= 800 or t1.ifoutoctetsmax/450000 >= 800)
      group by t2.citycn,t2.towncn,t2.nodecn,t2.ip,t2.address,t3.remark,t4.remark,
      t1.sampledate,t1.ac")
    end
    
    def get_ac_perf_aggr_hourly(date)
      find_by_sql("select t2.citycn,t2.towncn,t2.nodecn,t2.ip,t2.address,
      t3.remark ac_manu,t4.remark ac_type,t1.sampledate,t1.samplehour,
      t1.ac,t1.ifinoctetsmax/450000 ifin,t1.ifoutoctetsmax/450000 ifout
      from wlan_ac_perf_aggr t1,device_infos t2,dic_codes t3,dic_codes t4
      where t1.sampledate = to_date('#{date}','yyyy-mm-dd')
      and t1.busy_acnum = 1
      and t1.ac = t2.id(+)
      and t1.device_manu = t3.id(+)
      and t1.device_type = t4.id(+)")
    end
  end
end
