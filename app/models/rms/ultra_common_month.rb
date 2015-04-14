class Rms::UltraCommonMonth < External
  set_table_name "ppm_wlan_ap_key_perf_d"
  set_table_name "ppm_wlan_ac_performance_d"
  set_table_name "PPM_WLAN_AC_PERF_H"
  set_table_name "ppm_wlan_radius_performance_m"
  set_table_name  "device_infos"
  set_table_name  "ULTRA_WLAN_TMP_REPORT"
  set_table_name "ult_ppm_city_perf_m"
  class<<self
    def get_month_data_set(begin_time)
      find_by_sql("
        select * from ult_ppm_provice_perf_m where to_char(sampledate,'YYYYMM')='#{begin_time}'
        ")
    end

    def get_ac_month_data_set(begin_time,sort,order)
      find_by_sql("
  select
  trunc(wlnpze01,'MM') as sampledate,
  c.pro_name as nodecn,
  decode((sum(p.WLNPZE09)+sum(p.WLNPZE15)),0,0,round(sum(p.WLNPZE08)/(sum(p.WLNPZE09)+sum(p.WLNPZE15))*100,2)) as online_drops_rate,
  decode(sum(p.WLNPZE11),0,0,round(sum(p.WLNPZE10)/sum(p.WLNPZE11)*100,2)) as dhcpreqsuc_rate,
  decode(sum(p.WLNPZE13),0,0,round(sum(p.WLNPZE14)/sum(p.WLNPZE13)*100,2)) as dhcpuse_rate
  from ppm_wlan_ac_performance_d p,cfg_pro_cty c
  where p.wlnpze03 = c.pro_code and to_char(wlnpze01,'YYYYMM') ='#{begin_time}'
  group by trunc(p.wlnpze01,'MM'), c.pro_name order by #{sort} #{order}
        ")
    end

    def get_ac_show_month_set(begin_time,sort,order)
      find_by_sql("
         select trunc(f.wlnpm01, 'MM') as sampledate,
       c.pro_name as nodecn,
       sum(round(f.wlnpm09)) as ac_rxtyte,
       sum(round(f.wlnpm10)) as ac_txtyte,
       max(f.wlnpm11) as ac_max_user,
       max(f.wlnpm12) as ac_max_asso,
       round(avg(f.wlnpm13), 2) as ac_assosuc_rate
  from PPM_WLAN_AC_PERF_H f,cfg_pro_cty c
  where f.wlnpm03 = c.pro_code and to_char(f.wlnpm01,'YYYYMM')='#{begin_time}'
 group  by trunc(f.wlnpm01, 'MM'),c.pro_name
 order by #{sort} #{order}")
    end

    #luhao
       def get_ac_perf_data_city_m(begin_time,sort,order)
      find_by_sql("
   select
  trunc(wlnpze01,'MM') as sampledate,
  c.pro_name as nodecn,
  c.cty_name as citycn,
  decode((sum(p.WLNPZE09)+sum(p.WLNPZE15)),0,0,round(sum(p.WLNPZE08)/(sum(p.WLNPZE09)+sum(p.WLNPZE15))*100,2)) as online_drops_rate,
  decode(sum(p.WLNPZE11),0,0,round(sum(p.WLNPZE10)/sum(p.WLNPZE11)*100,2)) as dhcpreqsuc_rate,
  decode(sum(p.WLNPZE13),0,0,round(sum(p.WLNPZE14)/sum(p.WLNPZE13)*100,2)) as dhcpuse_rate
  from ppm_wlan_ac_performance_d p,cfg_pro_cty c
  where p.wlnpze03 = c.pro_code and to_char(wlnpze01,'YYYYMM') ='#{begin_time}'
  group by trunc(p.wlnpze01,'MM'), c.pro_name,c.cty_name order by #{sort} #{order}
        ")
    end

    def get_ap_perf_city_m(begin_time)
      find_by_sql("
        select sampledate,pro_name as nodecn,cty_name as citycn,ap_back,assocsucc_rate,rxbytes_max_rate,txbytes_max_rate,
      userdown_max_rate,abnormaldrops_rate,refused_rate,busyap_rate,idleap_rate,up_flow,
      down_flow,unkonew_rate,unsupport_rate,rssi_rate,max_online_rate,max_conncet_rate,
      busyap_num,busy_level,indoor_distribution_rate,indoor_put_pack_rate,outdool_distribution_rate,
      ap_empty_t_rate,ap_empty_a_rate,access_inf_strength,ap_num,ap_signal_system_rate from ult_ppm_city_perf_m where to_char(sampledate,'YYYYMM')='#{begin_time}'
        ")
    end
     def export_ap_perf_city_m
    ['sampledate','nodecn','citycn','ap_back','assocsucc_rate','rxbytes_max_rate','txbytes_max_rate',
      'userdown_max_rate','abnormaldrops_rate','refused_rate','busyap_rate','idleap_rate','up_flow',
      'down_flow','unkonew_rate','unsupport_rate','rssi_rate','max_online_rate','max_conncet_rate',
      'busyap_num','busy_level','indoor_distribution_rate','indoor_put_pack_rate','outdool_distribution_rate',
      'ap_empty_t_rate','ap_empty_a_rate','access_inf_strength','ap_num','ap_signal_system_rate'
      ]
    end

    def export_ac_perf_city_m
    ['sampledate','nodecn','citycn','online_drops_rate','dhcpreqsuc_rate','dhcpuse_rate']
    end
    #luhao *******************************end
    def get_years
      find_by_sql("
         select distinct(to_char(SAMPLEDATE,'YYYY')) years from ult_ppm_provice_perf_m order by years desc
        ")
    end
    def get_months(year)
      find_by_sql("
        select distinct(to_char(SAMPLEDATE,'MM')) monthes from ult_ppm_provice_perf_m  where to_char(SAMPLEDATE,'YYYY')='#{year}' order by monthes desc
        ")
    end

    
    def export_ap_month_data
    ['sampledate','nodecn','ap_back','assocsucc_rate','rxbytes_max_rate','txbytes_max_rate',
      'userdown_max_rate','abnormaldrops_rate','refused_rate','busyap_rate','idleap_rate','up_flow',
      'down_flow','unkonew_rate','unsupport_rate','rssi_rate','max_online_rate','max_conncet_rate',
      'busyap_num','busy_level','indoor_distribution_rate','indoor_put_pack_rate','outdool_distribution_rate',
      'ap_empty_t_rate','ap_empty_a_rate','access_inf_strength','ap_num','ap_signal_system_rate'
      ]
    end

    def export_ac_month_data
    ['sampledate','nodecn','online_drops_rate','dhcpreqsuc_rate','dhcpuse_rate']
    end

    def export_ac_month_show_data
      ['sampledate','nodecn','ac_rxtyte','ac_txtyte','ac_max_user','ac_max_asso','ac_assosuc_rate']
    end
  end
end
