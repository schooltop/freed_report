class Rms::UltraOnuDetail < External
  set_table_name "mit_sites_onu"
  set_table_name "mit_sites"
  class<<self
    def get_onu_detail(port,sort,order)
      find_by_sql("
        select
       ROW_NUMBER() over (order by #{sort} #{order}) as serial,
       t2.site_city,
       t2.wlan_site_name,
       t2.onu_name,
       t2.onu_ip,
       t2.belong_to_olt_ip,
       t2.belong_to_olt_chinese
  from (select id, site_cn from mit_sites) t1,
       (select site_city,
               wlan_site_name,
               onu_name,
               onu_ip,
               belong_to_olt_ip,
               belong_to_olt_chinese
          from mit_sites_onu) t2
 where t1.id = #{port}
   and t1.site_cn = t2.wlan_site_name
   order by #{sort} #{order}
        ")
    end
    def export_onu_detail
      ['serial','site_city','wlan_site_name','onu_name','onu_ip','belong_to_olt_ip','belong_to_olt_chinese']
    end
  end
end
