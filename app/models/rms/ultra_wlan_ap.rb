class Rms::UltraWlanAp < External
  set_table_name "ppm_wlan_ac_performance_d"
  set_table_name "PPM_WLAN_AC_PERF_H"
  set_table_name "ppm_wlan_radius_performance_m"
  set_table_name "ult_ppm_city_perf_d"
  set_table_name "ult_ppm_provice_perf_d"
  set_table_name "ult_ppm_provice_perf_m"
  set_table_name "ult_ppm_city_perf_m"
  set_table_name  "ULTRA_WLAN_TMP_REPORT"
  class<<self
    def get_data_set(begin_time,end_time,sort,order)
=begin
       find_by_sql("select t1.sampledate,t1.nodecn,t1.ap_back,t1.assocsucc_rate,t1.rxbytes_max_rate,t1.txbytes_max_rate,t1.userdown_max_rate,t1.abnormaldrops_rate,t1.busyap_rate,
decode(t1.ap_num,0,0,round(t1.idle_num/t1.ap_num*100,2)) as idleap_rate,
t1.refused_rate,t1.up_flow,t1.down_flow,t1.unkonew_rate,t1.unsupport_rate,
t1.rssi_rate,t1.max_online_rate,t1.max_conncet_rate,t1.busyap_num,t1.busy_level,
round(t1.indoor_distribution/ap_num*100,2) as indoor_distribution_rate,--室内分布
round(t1.indoor_put_pack/ap_num*100,2) as indoor_put_pack_rate,--室内放装
round(t1.outdool_distribution/ap_num*100,2) as outdool_distribution_rate,--室外分布
t1.ap_empty_t_rate,t1.ap_empty_a_rate,t1.access_inf_strength,
t1.ap_num,
'' as ap_signal_system_rate
 from
(select wlnpzb01 as sampledate,
               (select nodecn from device_infos where nodetype=0) as nodecn,
               round(sum(wlnpzb13)/(count(*)*15*60)*100,2) as ap_back,
               decode(sum(wlnpzb14)+sum(wlnpzb18),0,0,round((sum(wlnpzb14)+sum(wlnpzb18)-sum(wlnpzb15)-sum(wlnpzb20)) /(sum(wlnpzb14)+sum(wlnpzb18)) * 100,
                     2)) as assocsucc_rate,
               round(sum(wlnpzb17)/count(*),2) as rxbytes_max_rate,
               round(sum(wlnpzb19)/count(*),2) as txbytes_max_rate,
               max(wlnpzb21) as userdown_max_rate,
               decode(sum(wlnpzb25)+sum(wlnpzb14)+sum(wlnpzb18)-sum(wlnpzb15)-sum(wlnpzb20),0,0,round(sum(wlnpzb22)/(sum(wlnpzb25)+sum(wlnpzb14)+sum(wlnpzb18)-sum(wlnpzb15)-sum(wlnpzb20)) * 100,
                     2)) as abnormaldrops_rate,
               round(sum(wlnpzb31)/count(*)*100,2) as busyap_rate,
               count(*) as ap_num, --AP总数
               decode(sum(wlnpzb14)+sum(wlnpzb18),0,0,round(sum(wlnpzb23)/(sum(wlnpzb14)+sum(wlnpzb18)) * 100, 2)) as refused_rate,
							 sum(wlnpzb29) as up_flow,--上行流量
							 sum(wlnpzb30) as down_flow,--下行流量
							 decode(sum(wlnpzb14)+sum(wlnpzb18),0,0,round(sum(wlnpzb26)/(sum(wlnpzb14)+sum(wlnpzb18))*100,2)) as unkonew_rate,--由于之前的关联无法识别与转移而导致重新关联失败率（%）
							 decode(sum(wlnpzb14)+sum(wlnpzb18),0,0,round(sum(wlnpzb27)/(sum(wlnpzb14)+sum(wlnpzb18))*100,2)) as unsupport_rate,--因终端不支持基本速率集要求的速率而关联失败的失败率（%）
							 decode(sum(wlnpzb14)+sum(wlnpzb18),0,0,round(sum(wlnpzb28)/(sum(wlnpzb14)+sum(wlnpzb18))*100,2)) as rssi_rate,--因RSSI过低而关联失败的失败率（%）
							 sum(wlnpzb41) as max_online_rate,-- 峰值在线用户数
							 sum(wlnpzb42) as max_conncet_rate,--峰值关联终端用户数
							 sum(wlnpzb31) as busyap_num,--超忙AP个数
							 decode(sum(wlnpzb33),0,0,round(sum(wlnpzb32)/sum(wlnpzb33)*100,2)) as busy_level,--超忙AP程度
							 decode(sum(wlnpzb36),0,0,round(sum(wlnpzb35)/sum(wlnpzb36)*100,2)) as ap_empty_t_rate, --AP空口下行重传率
							 decode(sum(wlnpzb38),0,0,round(sum(wlnpzb37)/sum(wlnpzb38)*100,2)) as ap_empty_a_rate, --AP空口收包错误率
							 round(avg(wlnpzb39),2) as access_inf_strength,
               count(case when wlnpzb34='室分' then 1 else null end ) indoor_distribution,
               count(case when wlnpzb34='放装' then 1 else null end ) indoor_put_pack,
               count(case when wlnpzb34='室外' then 1 else null end ) outdool_distribution,
               sum( case
         WHEN nvl((wlnpzb29 + wlnpzb30), 0) < 10 then
          1
         else
          0
       end) idle_num
          from ppm_wlan_ap_key_perf_d
         where wlnpzb01 >=to_date('#{begin_time}','YYYY-MM-DD')
               and wlnpzb01<=to_date('#{end_time}','YYYY-MM-DD')
         group by wlnpzb01) t1
         order by #{sort} #{order}
    ")
=end
       find_by_sql("select sampledate,pro_name as nodecn,ap_back,assocsucc_rate,rxbytes_max_rate,txbytes_max_rate,
      userdown_max_rate,abnormaldrops_rate,refused_rate,busyap_rate,idleap_rate,up_flow,
      down_flow,unkonew_rate,unsupport_rate,rssi_rate,max_online_rate,max_conncet_rate,
      busyap_num,busy_level,indoor_distribution_rate,indoor_put_pack_rate,outdool_distribution_rate,
      ap_empty_t_rate,ap_empty_a_rate,access_inf_strength,ap_num,ap_signal_system_rate
         from ult_ppm_provice_perf_d
           where sampledate >=to_date('#{begin_time}','YYYY-MM-DD')
               and sampledate<=to_date('#{end_time}','YYYY-MM-DD')
                order by #{sort} #{order}")
    end

  def get_ac_data_set(begin_time,end_time,sort,order)
    find_by_sql("
     select
  p.wlnpze01 as sampledate,
  c.pro_name as nodecn,
  decode((sum(p.WLNPZE09+p.WLNPZE15)),0,0,round(sum(p.WLNPZE08)/(sum(p.WLNPZE09+p.WLNPZE15))*100,2)) as online_drops_rate,
  decode(sum(p.WLNPZE11),0,0,round(sum(p.WLNPZE10)/sum(p.WLNPZE11)*100,2)) as dhcpreqsuc_rate,
  decode(sum(p.WLNPZE13),0,0,round(sum(p.WLNPZE14)/sum(p.WLNPZE13)*100,2)) as dhcpuse_rate
  from ppm_wlan_ac_performance_d p,(select pro_name,pro_code from cfg_pro_cty  group by pro_name,pro_code) c
  where p.wlnpze03 = c.pro_code and p.wlnpze01>=to_date('#{begin_time}','YYYY-MM-DD')
  and p.wlnpze01<=to_date('#{end_time}','YYYY-MM-DD')
  group by p.wlnpze01, c.pro_name order by #{sort} #{order}
      ")
  end
#***********************luhao start****************************
 def get_ap_data_city_d(begin_time,end_time,sort,order)
       find_by_sql("select sampledate,pro_name as nodecn,cty_name as citycn,ap_back,assocsucc_rate,rxbytes_max_rate,txbytes_max_rate,
      userdown_max_rate,abnormaldrops_rate,refused_rate,busyap_rate,idleap_rate,up_flow,
      down_flow,unkonew_rate,unsupport_rate,rssi_rate,max_online_rate,max_conncet_rate,
      busyap_num,busy_level,indoor_distribution_rate,indoor_put_pack_rate,outdool_distribution_rate,
      ap_empty_t_rate,ap_empty_a_rate,access_inf_strength,ap_num,ap_signal_system_rate
         from ult_ppm_city_perf_d
           where sampledate >=to_date('#{begin_time}','YYYY-MM-DD')
               and sampledate<=to_date('#{end_time}','YYYY-MM-DD')
                order by #{sort} #{order}
    ")
    end

   
  def get_ac_data_city_d(begin_time,end_time,sort,order)
    find_by_sql("
    select
  p.wlnpze01 as sampledate,
  c.pro_name as nodecn,
  c.cty_name as citycn,
  decode((sum(p.WLNPZE09+p.WLNPZE15)),0,0,round(sum(p.WLNPZE08)/(sum(p.WLNPZE09+p.WLNPZE15))*100,2)) as online_drops_rate,
  decode(sum(p.WLNPZE11),0,0,round(sum(p.WLNPZE10)/sum(p.WLNPZE11)*100,2)) as dhcpreqsuc_rate,
  decode(sum(p.WLNPZE13),0,0,round(sum(p.WLNPZE14)/sum(p.WLNPZE13)*100,2)) as dhcpuse_rate
  from ppm_wlan_ac_performance_d p,cfg_pro_cty c
  where p.wlnpze04 = c.cty_code and p.wlnpze03 = c.pro_code and (p.wlnpze01>=to_date('#{begin_time}','YYYY-MM-DD')
  and p.wlnpze01<=to_date('#{end_time}','YYYY-MM-DD'))
  group by p.wlnpze01, c.pro_name,c.cty_name order by #{sort} #{order}
      ")
  end
  def get_ac_show_data_city_d(begin_time,end_time,sort,order)
    find_by_sql("
          select trunc(f.wlnpm01,'DD') as sampledate,
 c.pro_name as nodecn,
 c.cty_name as citycn,
 sum(round(f.wlnpm09)) as ac_rxtyte,
 sum(round(f.wlnpm10)) as ac_txtyte,
 max(f.wlnpm11) as ac_max_user,
 max(f.wlnpm12) as ac_max_asso,
 round(avg(f.wlnpm13),2) as ac_assosuc_rate
     from PPM_WLAN_AC_PERF_H f,cfg_pro_cty c
      where f.wlnpm05 = c.cty_code and f.wlnpm03= c.pro_code and (f.wlnpm01 >=to_date('#{begin_time}','YYYY-MM-DD')
      and f.wlnpm01 <to_date('#{end_time}','YYYY-MM-DD')+1)
       group by trunc(f.wlnpm01,'DD'),c.pro_name,c.cty_nameorder by #{sort} #{order}
      ")
  end
         def get_ac_perf_data_city_m(begin_time,sort,order)
      find_by_sql("
   select pp.sampledate        as sampledate,
       c.pro_name           as nodecn,
       c.cty_name           as citycn,
       pp.online_drops_rate as online_drops_rate,
       pp.dhcpreqsuc_rate as dhcpreqsuc_rate,
       pp.dhcpuse_rate as dhcpuse_rate
  from (select trunc(wlnpze01, 'MM') as sampledate,
               p.wlnpze03,
               p.wlnpze04,
               decode(sum(p.WLNPZE09 + p.WLNPZE15),
                      0,
                      0,
                      round(sum(p.WLNPZE08) /
                            (sum(p.WLNPZE09 + p.WLNPZE15)) * 100,
                            2)) as online_drops_rate,
               decode(sum(p.WLNPZE11),
                      0,
                      0,
                      round(sum(p.WLNPZE10) / sum(p.WLNPZE11) * 100, 2)) as dhcpreqsuc_rate,
               decode(sum(p.WLNPZE13),
                      0,
                      0,
                      round(sum(p.WLNPZE14) / sum(p.WLNPZE13) * 100, 2)) as dhcpuse_rate
          from ppm_wlan_ac_performance_d p
         where to_char(wlnpze01, 'YYYYMM') = '#{begin_time}'
         group by trunc(p.wlnpze01, 'MM'), p.wlnpze03, p.wlnpze04
         order by sampledate ASC) pp,
       cfg_pro_cty c
 where pp.wlnpze03 = c.pro_code
   and pp.wlnpze04 = c.cty_code order by #{sort} #{order}
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
     def export_ap_perf_city
    ['sampledate','nodecn','citycn','ap_back','assocsucc_rate','rxbytes_max_rate','txbytes_max_rate',
      'userdown_max_rate','abnormaldrops_rate','refused_rate','busyap_rate','idleap_rate','up_flow',
      'down_flow','unkonew_rate','unsupport_rate','rssi_rate','max_online_rate','max_conncet_rate',
      'busyap_num','busy_level','indoor_distribution_rate','indoor_put_pack_rate','outdool_distribution_rate',
      'ap_empty_t_rate','ap_empty_a_rate','access_inf_strength','ap_num','ap_signal_system_rate'
      ]
    end
      def export_ac_data_city
    ['sampledate','nodecn','citycn','online_drops_rate','dhcpreqsuc_rate','dhcpuse_rate']
  end

      def export_ac_show_data_city
    ['sampledate','nodecn','citycn','ac_rxtyte','ac_txtyte','ac_max_user','ac_max_asso','ac_assosuc_rate']
  end
  #**************************luhao end*************************
  def get_ac_show_data_set(begin_time,end_time,sort,order)
    find_by_sql("
          select trunc(f.wlnpm01,'DD') as sampledate,
 c.pro_name as nodecn,
 sum(round(f.wlnpm09)) as ac_rxtyte,
 sum(round(f.wlnpm10)) as ac_txtyte,
 max(f.wlnpm11) as ac_max_user,
 max(f.wlnpm12) as ac_max_asso,
 round(avg(f.wlnpm13),2) as ac_assosuc_rate
     from PPM_WLAN_AC_PERF_H f,(select pro_name,pro_code from cfg_pro_cty  group by pro_name,pro_code) c
      where f.wlnpm03 = c.pro_code and f.wlnpm01 >=to_date('#{begin_time}','YYYY-MM-DD')
      and f.wlnpm01 <to_date('#{end_time}','YYYY-MM-DD')+1
       group by trunc(f.wlnpm01,'DD'),c.pro_name order by #{sort} #{order}
      ")
  end

  def get_portal_data_set(begin_time,sort,order)
   find_by_sql("
        select e.wlnpzg01 as sampledate,
         c.pro_name as nodecn,
         sum(e.WLNPZG06) as regist_num,
         sum(e.WLNPZG07) as active_num,
         sum(e.WLNPZG08) as req_time,
         sum(e.WLNPZG09) as fee_time,
         sum(e.WLNPZG10) / 1000 / 1000 / 1000 as flow
    from ppm_wlan_radius_performance_m e,(select pro_name,pro_code from cfg_pro_cty  group by pro_name,pro_code) c
   where e.wlnpzg03 = c.pro_code and to_char(e.wlnpzg01,'YYYYMM')='#{begin_time}'
   group by e.wlnpzg01 ,c.pro_name order by #{sort} #{order}
      ")
  end
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
  from ppm_wlan_ac_performance_d p,(select pro_name,pro_code from cfg_pro_cty  group by pro_name,pro_code) c
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
  from PPM_WLAN_AC_PERF_H f,(select pro_name,pro_code from cfg_pro_cty  group by pro_name,pro_code) c
  where f.wlnpm03 = c.pro_code and to_char(f.wlnpm01,'YYYYMM')='#{begin_time}'
 group  by trunc(f.wlnpm01, 'MM'),c.pro_name
 order by #{sort} #{order}")
    end
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
  def get_port_years
    find_by_sql(" select distinct(to_char(wlnpzg01,'YYYY')) years from ppm_wlan_radius_performance_m order by years")
  end

  def get_port_months(year)
    find_by_sql("select distinct(to_char(wlnpzg01,'MM')) monthes from ppm_wlan_radius_performance_m  where to_char(wlnpzg01,'YYYY')='#{year}' order by monthes desc")
  end
  def export_ap_data
    ['sampledate','nodecn','ap_back','assocsucc_rate','rxbytes_max_rate','txbytes_max_rate',
      'userdown_max_rate','abnormaldrops_rate','refused_rate','busyap_rate','idleap_rate','up_flow',
      'down_flow','unkonew_rate','unsupport_rate','rssi_rate','max_online_rate','max_conncet_rate',
      'busyap_num','busy_level','indoor_distribution_rate','indoor_put_pack_rate','outdool_distribution_rate',
      'ap_empty_t_rate','ap_empty_a_rate','access_inf_strength','ap_num','ap_signal_system_rate'
      ]
  end

  def export_ac_data
    ['sampledate','nodecn','online_drops_rate','dhcpreqsuc_rate','dhcpuse_rate']
  end

  def export_ac_show_data
    ['sampledate','nodecn','ac_rxtyte','ac_txtyte','ac_max_user','ac_max_asso','ac_assosuc_rate']
  end

  def export_portal_data
    ['sampledate','nodecn','regist_num','active_num','req_time','fee_time','flow']
  end
  end
end
