class Rms::UltraAcDetail < External
  set_table_name "mit_sites"
  set_table_name "mit_acs"
  set_table_name "device_infos"
  set_table_name "mit_aps"
  set_table_name "wlan_ac_perf_aggr_day"
  set_table_name "dic_types"
  set_table_name "dic_codes"
  class<<self
    def get_ac_detail(port,time,sort,order)
      today=Date.current.strftime("%Y-%m-%d")
      if time.eql?(today)
        find_by_sql("
      select
       ROW_NUMBER() over (order by #{sort} #{order}) as serial,
       t7.accn,
       t7.ip,
       t7.citycn,
       t9.code_name as devie_manu,
       t8.code_name as ac_type,
       t7.address,
       t7.ap_num,
       decode(t5.dhcpreqtimes,
                      0,
                      0,
                      round(t5.dhcpreqsuctimes / t5.dhcpreqtimes * 100, 2)) as dhcp_req_rate,
       round((t6.ac_ifinoctets + t6.ac_ifoutoctets) / 1000, 2) as ac_octes
  from (select t3.accn,
               t3.ip,
               t3.citycn,
               t3.device_manu,
               t2.ac_type,
               t3.address,
               t4.ap_num,
							 t3.ac
          from (select ac_id, id from mit_sites) t1,
               (select id, ac_dn, ac_type from mit_acs) t2,
               device_infos t3,
               (select port, count(id) as ap_num from mit_aps group by port) t4
         where t1.ac_id = t2.id
           and t1.id = t4.port
           and t1.id = #{port}
           and t3.nodedn = t2.ac_dn
					 and t3.nodetype=8
					 ) t7
	left join (select ac,
                       sum(dhcpreqsuctimes) as dhcpreqsuctimes,
                       sum(dhcpreqtimes) as dhcpreqtimes
                  from wlan_ac_perf_aggr_day
                 where sampledate >= add_months(trunc(sysdate, 'MM'), -1)
                   and sampledate <= add_months(trunc(last_day(sysdate)), -1)
                 group by ac) t5 on t5.ac=t7.ac
  left join  (select ac,
                       sum(ac_ifinoctets) as ac_ifinoctets,
                       sum(ac_ifoutoctets) as ac_ifoutoctets
                  from wlan_ac_perf_aggr
                  where sampledate=trunc(sysdate)
                  and samplehour <=(select to_number(to_char(sysdate,'hh24')) from dual)
                  group by ac
                   ) t6 on t6.ac=t7.ac
  left join (select id, code_name
               from dic_codes
              where type_id =
                    (select id from dic_types where type_name = 'ac_type')) t8
    on t7.ac_type = t8.id
  left join (select id, code_name
               from dic_codes
              where type_id =
                    (select id from dic_types where type_name = 'device_manu')) t9
    on t7.device_manu = t9.id
          ")
      else
      find_by_sql("
        select
       ROW_NUMBER() over (order by #{sort} #{order}) as serial,
       t7.accn,
       t7.ip,
       t7.citycn,
       t9.code_name as devie_manu,
       t8.code_name as ac_type,
       t7.address,
       t7.ap_num,
       decode(t5.dhcpreqtimes,
                      0,
                      0,
                      round(t5.dhcpreqsuctimes / t5.dhcpreqtimes * 100, 2)) as dhcp_req_rate,
       round((t6.ac_ifinoctets + t6.ac_ifoutoctets) / 1000, 2) as ac_octes
  from (select t3.accn,
               t3.ip,
               t3.citycn,
               t3.device_manu,
               t2.ac_type,
               t3.address,
               t4.ap_num,
							 t3.ac
          from (select ac_id, id from mit_sites) t1,
               (select id, ac_dn, ac_type from mit_acs) t2,
               device_infos t3,
               (select port, count(id) as ap_num from mit_aps group by port) t4
         where t1.ac_id = t2.id
           and t1.id = t4.port
           and t1.id = #{port}
           and t3.nodedn = t2.ac_dn
					 and t3.nodetype=8
					 ) t7
	left join (select ac,
                       sum(dhcpreqsuctimes) as dhcpreqsuctimes,
                       sum(dhcpreqtimes) as dhcpreqtimes
                  from wlan_ac_perf_aggr_day
                 where sampledate >= add_months(trunc(sysdate, 'MM'), -1)
                   and sampledate <= add_months(trunc(last_day(sysdate)), -1)
                 group by ac) t5 on t5.ac=t7.ac
  left join  wlan_ac_perf_aggr_day t6 on t6.ac=t7.ac	and t6.sampledate = to_date('#{time}', 'YYYY-MM-DD')
  left join (select id, code_name
               from dic_codes
              where type_id =
                    (select id from dic_types where type_name = 'ac_type')) t8
    on t7.ac_type = t8.id
  left join (select id, code_name
               from dic_codes
              where type_id =
                    (select id from dic_types where type_name = 'device_manu')) t9
    on t7.device_manu = t9.id
        ")
      end
    end
    def export_ac_detail
      ['serial','accn','ip','citycn','devie_manu','ac_type','address','ap_num','dhcp_req_rate','ac_octes']
    end
  end
end
