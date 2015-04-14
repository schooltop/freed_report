class Rms::UltraApDetail < External
  set_table_name "device_infos"
  set_table_name "wlan_ap_perf_aggr_month"
  set_table_name "wlan_ap_perf_aggr_day"
  class<<self
    def get_ap_detail(port,time,sort,order)
     today=Date.current.strftime("%Y-%m-%d")
    if time.eql?(today)
      p "**********************************::::::::::::::"
      find_by_sql("
 select ROW_NUMBER() over (order by #{sort} #{order}) as serial,
        t5.apcn,
        t5.ip,
        t5.citycn,
        t5.accn,
        t5.portcn,
				decode(t3.pingall_count,
              0,
              0,
              round((t3.pingall_count - t3.pingok_count) * 100 /
                    t3.pingall_count,
                    2)) as ap_back,
				round((t4.rxbytestotal + t4.txbytestotal) / 1000, 2) as liuliang
				  from (
 select t2.apcn,
        t2.ip,
        t2.citycn,
        t2.accn,
        t2.portcn,
			  t2.ap  from mit_aps t1
 left join device_infos t2 on t1.ap_dn=t2.nodedn and t2.nodetype=11
 where t1.port=#{port}) t5
left join wlan_ap_perf_aggr_month t3 on t3.ap=t5.ap and t3.sampledate=add_months(trunc(last_day(sysdate)), -1)
left join  (select ap,sum(rxbytestotal) as rxbytestotal,sum(txbytestotal) as txbytestotal from wlan_ap_perf_aggr
			 where sampledate=trunc(sysdate) and samplehour <=(select to_number(to_char(sysdate,'hh24')) from dual) group by ap)   t4 on t4.ap=t5.ap
          ")
    else
      find_by_sql("
  select
       ROW_NUMBER() over (order by #{sort} #{order}) as serial,
        t5.apcn,
        t5.ip,
        t5.citycn,
        t5.accn,
        t5.portcn,
				decode(t3.pingall_count,
              0,
              0,
              round((t3.pingall_count - t3.pingok_count) * 100 /
                    t3.pingall_count,
                    2)) as ap_back,
				round((t4.rxbytestotal + t4.txbytestotal) / 1000, 2) as liuliang
				  from (
 select t2.apcn,
        t2.ip,
        t2.citycn,
        t2.accn,
        t2.portcn,
			  t2.ap  from mit_aps t1
 left join device_infos t2 on t1.ap_dn=t2.nodedn and t2.nodetype=11
 where t1.port=#{port}) t5
left join wlan_ap_perf_aggr_month t3 on t3.ap=t5.ap and t3.sampledate=add_months(trunc(last_day(sysdate)), -1)
left join wlan_ap_perf_aggr_day t4 on t4.ap=t5.ap and t4.sampledate=to_date('#{time}','YYYY-MM-DD')
      ")
    end
    
    end

    def export_ap_detail
      ['serial','apcn','ip','citycn','accn','portcn','ap_back','liuliang']
    end
  end
end
