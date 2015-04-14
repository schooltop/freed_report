class Rms::UltraWlanSite < External
  set_table_name "mit_sites"
  set_table_name "mit_aps"
  set_table_name "mit_switchs"
  set_table_name "mit_acs"
  set_table_name "wlan_ac_perf_aggr_day"
  set_table_name "MIT_SITES_ONU"
  set_table_name "DIC_TYPES"
  set_table_name "DIC_CODES"
  class<<self
    def get_wlan_site(sort,order,cond)
      find_by_sql("
select  to_char(ROW_NUMBER() over (order by #{sort} #{order})) as  serial,id,
code_name,site_cn,ac_num,
ap_num,sw_poe_num,sw_con_num,
oun_num
from(
select '' as serial,
       mit_sites.id,
       t7.code_name,
       mit_sites.site_cn,
       t5.ac_num,
       t1.ap_num,
       t2.sw_poe_num,
       0 as sw_con_num,
       t6.oun_num
  from mit_sites
  left join (select t4.port,t4.ap_num from
             (select ac_id, id from mit_sites) t8,
               (select id, ac_dn, ac_type from mit_acs) t9,
               (select port, count(id) as ap_num from mit_aps group by port) t4
                 where t8.ac_id=t9.id and t8.id=t4.port) t1
    on t1.port = mit_sites.id 
  left join (select port, count(id) as sw_poe_num
               from mit_switchs
              group by port) t2
    on t2.port = mit_sites.id
  left join (select id, count(ac_id) as ac_num
               from mit_sites
              where site_type = 3
              group by id) t5
    on t5.id = mit_sites.id
  left join (select wlan_site_name, count(onu_name) as oun_num
               from mit_sites_onu
              group by wlan_site_name) t6
    on t6.wlan_site_name = mit_sites.site_cn
  left join (select id, code_name
               from dic_codes
              where dic_codes.type_id =
                    (select id
                       from dic_types
                      where dic_types.type_name = 'port_type')) t7
    on t7.id = mit_sites.port_type
 where mit_sites.site_type = 3  #{cond})
union all
select serial,id,site_type,site_cn,ac_num,ap_num,sw_poe_num,sw_con_num,oum_num
 from (
select '合计' as serial,
       0 as id,
       '' as site_type,
       '' as site_cn,
       sum(t5.ac_num) as ac_num,
       sum(t1.ap_num) ap_num,
       sum(t2.sw_poe_num) as sw_poe_num,
       0 as sw_con_num,
       sum(t6.oun_num) as oum_num
  from mit_sites
  left join (select port, count(id) as ap_num from mit_aps group by port) t1
    on t1.port = mit_sites.id
  left join (select port, count(id) as sw_poe_num
               from mit_switchs
              group by port) t2
    on t2.port = mit_sites.id
  left join (select id, count(ac_id) as ac_num
               from mit_sites
              where site_type = 3
              group by id) t5
    on t5.id = mit_sites.id
  left join (select wlan_site_name, count(onu_name) as oun_num
               from mit_sites_onu
              group by wlan_site_name) t6
    on t6.wlan_site_name = mit_sites.site_cn
  left join (select id, code_name
               from dic_codes
              where dic_codes.type_id =
                    (select id
                       from dic_types
                      where dic_types.type_name = 'port_type')) t7
    on t7.id = mit_sites.port_type
   where mit_sites.site_type = 3  #{cond})
")
    end

    def export_wlan_site
      ['serial','code_name','site_cn','ac_num','ap_num','sw_poe_num','sw_con_num','oun_num','dhcp_req_rate','ac_octes']
    end

  end
end
