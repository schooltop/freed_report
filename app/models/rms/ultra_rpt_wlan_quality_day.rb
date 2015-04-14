class Rms::UltraRptWlanQualityDay < External
  set_table_name "ultra_rpt_wlan_quality_day"
  class<<self
    def get_cq_portal_data(begin_time,end_time,sort,order)
      find_by_sql("
        select riqi,'直辖市'as province,(allcount-failcode1-failcode2-failcode3-failcode4-failcode6) as chllengeall,
        round((allcount-failcode1-failcode2-failcode3-failcode4-failcode6-accode1-accode2-accode3-accode4)*100/(allcount-failcode1-failcode2-failcode3-failcode4-failcode6),8) as chllengerate,
        round((1-(accode4/allcount))*100,8) as ac_port_rate from ultra_rpt_wlan_quality_day where riqi>=to_date('#{begin_time}','YYYY-MM-DD') and riqi<=to_date('#{end_time}','YYYY-MM-DD') order by #{sort} #{order}
        ")
    end

    def export_cq_portal_data
      ['riqi','province','chllengeall','chllengerate','ac_port_rate']
    end
  end
end
