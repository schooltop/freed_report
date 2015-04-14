class Rms::WlanTownPerfAggrDay < External
  set_table_name "wlan_town_perf_aggr_day"
  set_sequence_name "wlan_seq_infos"

  class << self
    def get_ap_avail_rate_of_city(date)
      find_by_sql("select t1.sampledate,t2.nodecn city_name,
        decode(sum(nvl(t1.pingall_count,0)),0,0,sum(nvl(t1.pingok_count,0))/sum(nvl(t1.pingall_count,0))) ap_avail_rate
        from wlan_town_perf_aggr_day t1,device_infos t2
        where t1.sampledate = to_date('#{date}','yyyy-mm-dd')
        and t1.city = t2.id(+)
        and t2.nodetype(+) = 1
        group by t1.sampledate,t2.nodecn")
    end
  end
end
