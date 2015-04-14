class Rms::WlanApPerfAggrDay < External
  set_table_name "wlan_ap_perf_aggr_day"
  set_sequence_name "wlan_seq_infos"
  class << self
    def get_ap_perf_aggr_day(date,filter_type)
      find_by_sql("select t2.citycn,t2.towncn,t2.portcn,t3.remark porttype,
      t2.nodecn apcn,t2.mac,t2.ip,t2.address,t4.remark ap_manu,
      t5.remark ap_type,t1.sampledate,
      decode(sum(t1.ctapall),0,0,sum(t1.ctapall - t1.ctapok)/sum(t1.ctapall)) out_service,
      sum(t1.aponlinenum) aponlinenum,sum(t1.txbytestotalmax)/450000 maxtxbytes,sum(t1.refusednum) refusednum,
      sum(t1.assocnum) assocnum,
      decode(sum(t1.assocnum + t1.reassocnum),0,0,sum(t1.refusednum)/sum(t1.assocnum + t1.reassocnum)) congest_rate,
      sum(t1.deauthnum) deauthnum,sum(t1.assocsuccnum) assocsuccnum,sum(t1.reassocsuccnum) reassocsuccnum,
      decode(sum(t1.assocsuccnum + t1.reassocsuccnum),0,0,sum(t1.deauthnum)/sum(t1.assocsuccnum +t1.reassocsuccnum)) off_line_rate,
      sum(t1.txbytestotal)/1000 txbytes,sum(t1.rxbytestotal)/1000 rxbytes,sum(t1.txbytestotal+t1.rxbytestotal)/1000 wireless_traffic
      from wlan_ap_perf_aggr_day t1,device_infos t2,
      dic_codes t3,dic_codes t4,dic_codes t5
      where t1.sampledate = to_date('#{date}','yyyy-mm-dd')
      and t1.#{filter_type} = 1
      and t1.ap = t2.id(+)
      and t2.port_type = t3.id(+)
      and t1.device_manu = t4.id(+)
      and t1.device_type = t5.id(+)
      group by t2.citycn,t2.towncn,t2.portcn,t3.remark,t2.nodecn,t2.mac,t2.ip,t2.address,t4.remark,
      t5.remark,t1.sampledate")
    end

    def acceptance_criteria(cityid)
      unless cityid ==0
        con = "  and t1.cityid = #{cityid}"
      end
      date = Date.yesterday.strftime("%Y-%m-%d")
      find_by_sql("select t2.citycn city_name,count(distinct decode(t2.check_state,1,t1.ap,null)) check_ap,
      count(distinct decode(t2.check_state,1,null,t1.ap)) uncheck_ap,
      sum(decode(t2.check_state,1,pingall_count-pingok_count,0))/(sum(decode(t2.check_state,1,pingall_count,0))+0.00001) check_rate,
      sum(decode(t2.check_state,1,0,pingall_count-pingok_count))/(sum(decode(t2.check_state,1,0,pingall_count))+0.00001) uncheck_rate,
      sum(aponlinenummax)/sum(apall*hournum) onlinenum_ap
      from wlan_ap_perf_aggr_day t1,config_infos t2
      where  t1.ap = t2.ap(+)
      and t2.nodetype = 11
      and t1.sampledate = to_date('#{date}','yyyy-mm-dd') #{con}
      group by t2.citycn
      order by t2.citycn")
    end
  end
end
