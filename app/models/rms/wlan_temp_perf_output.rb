class Rms::WlanTempPerfOutput < External
  set_table_name "wlan_temp_perf_output"
  set_sequence_name "wlan_seq_infos"

  def  self.user_details(page,login,year,month,sort)
    query_cons={}
    query_cons[:from]="wlan_auth_session_aggr t1,device_infos t2"
    query_cons[:select]="t2.citycn,t2.portcn,t1.login,t1.start_time,t1.end_time,
        decode(t1.net_type,1,'WLAN',2,'EVDO',3,'CDMA1X','WLAN') net_types,
        t1.bts_name||'_'||t1.cell_no cellcn,
        decode(t1.dial_type,0,t1.bytes_in,t1.rm_bytes_in)/1000000 rec_bytes,
        decode(t1.dial_type,0,t1.bytes_out,t1.rm_bytes_out)/1000000 sen_bytes,
        decode(t1.dial_type,0,t1.period_time,t1.rm_period_time) time_length"
    query_cons[:conditions]=" t1.port = t2.id(+) and t2.nodetype = 5 and login = '#{login}' and sampleyear = #{year} and samplemonth = #{month}"
    attach_sort_option(query_cons,sort)
    if page.blank?
      all query_cons
    else
      paginate query_cons.merge(:page=>page,:per_page=>30)
    end

  end

  def self.generate_quality_perf(worksheet,guid,border)
    header = ["省份","AC流入流量(MB)","AC流出流量(MB)","在线用户异常掉线率(AC)","DHCP请求次数","DHCP请求成功数",
      "DHCP的IP地址分配成功率","关联终端异常掉线率(AP)","AC峰值流入速率(Kbps)","AC峰值流出速率(Kbps)","超忙AC数量",
      "AP平均关联终端数","AP峰值关联终端数","AP峰值在线用户数","AP平均在线用户数","AP退服率(%)","AP设备平均利用率(%)",
      "AP设备峰值利用率(%)","AP关联拥塞率(%)","AP关联成功率(%)","无线上行流量(KB)","无线上行速率(Kbps)","无线下行流量(KB)",
      "无线下行速率(Kbps)","超忙AP数量","超闲AP数量","最差AP数量"]
    write_header(worksheet,header,border)
    @quality = self.find_by_sql("
      select '全省' province_name,t1.kpi104 ac_in_flow,t1.kpi110 ac_out_flow,
      t1.kpi98 abnormal_lineoff_rate,t1.kpi69 dhcp_request,t1.kpi70 dhcp_request_succ,
      t1.kpi71 dhcp_addr,t1.kpi64 assoc_lineoff_rate,'' ac_max_in_flow,
     	'' ac_max_out_flow,t1.kpi74 busy_acnum,t1.kpi30 ap_avg_relate,
      t1.kpi29 ap_max_relate,t1.kpi24 ap_max_online,t1.kpi66 ap_avg_online,t1.kpi125 ap_out_of_service,
    	t1.kpi9 ap_resource_avg_used,t1.kpi48 ap_resource_max_used,t1.kpi33 ap_relate_congest_rate,
      t1.kpi32 ap_assocsucc_rate,nvl(t1.kpi1,0) * 1000 ap_up_traffic,(nvl(t1.kpi22,0) * 1000) ap_up_rate,
      nvl(t1.kpi6,0) * 1000 ap_down_flow,(nvl(t1.kpi34,0) * 1000) ap_down_rate,t1.kpi52 busy_apnum,
      t1.kpi53 idle_apnum,t1.kpi68 bad_apnum
      from results.result_#{guid}_0 t1")
    row = 1
    @quality.each do |quality|
      content = [quality.province_name,two_decimal_digit(quality.ac_in_flow),two_decimal_digit(quality.ac_out_flow),
        conv_to_percent(quality.abnormal_lineoff_rate),quality.dhcp_request,quality.dhcp_request_succ,
        conv_to_percent(quality.dhcp_addr),conv_to_percent(quality.assoc_lineoff_rate),
        two_decimal_digit(quality.ac_max_in_flow),two_decimal_digit(quality.ac_max_out_flow),
        quality.busy_acnum,quality.ap_avg_relate,quality.ap_max_relate,quality.ap_max_online,quality.ap_avg_online,
        conv_to_percent(quality.ap_out_of_service),conv_to_percent(quality.ap_resource_avg_used),
        conv_to_percent(quality.ap_resource_max_used),conv_to_percent(quality.ap_relate_congest_rate),
        conv_to_percent(quality.ap_assocsucc_rate),two_decimal_digit(quality.ap_up_traffic),
        two_decimal_digit(quality.ap_up_rate),two_decimal_digit(quality.ap_down_flow),
        two_decimal_digit(quality.ap_down_rate),quality.busy_apnum,quality.idle_apnum,quality.bad_apnum]
      write_content(worksheet,content,row)
      row += 1
    end
  end

  def self.generate_school_quality_perf(worksheet,guid,border)
    header = ["省份","AP平均关联终端数","AP峰值关联终端数","AP峰值在线用户数","AP平均在线用户数","AP退服率(%)","AP设备平均利用率(%)",
      "AP设备峰值利用率(%)","AP关联拥塞率(%)","AP关联成功率(%)","无线上行流量(KB)","无线上行速率(Kbps)","无线下行流量(KB)",
      "无线下行速率(Kbps)","超忙AP数量","超闲AP数量","最差AP数量"]
    write_header(worksheet,header,border)
    @school_quality = Rms::WlanTempPerfOutput.find_by_sql("
      select '全省' province_name,t1.kpi30 ap_avg_relate,t1.kpi29 ap_max_relate,t1.kpi24 ap_max_online,
      t1.kpi66 ap_avg_online,t1.kpi125 ap_out_of_service,t1.kpi9 ap_resource_avg_used,
      t1.kpi48 ap_resource_max_used,t1.kpi33 ap_relate_congest_rate,t1.kpi32 ap_assocsucc_rate,
      nvl(t1.kpi1,0) * 1000 ap_up_traffic,(nvl(t1.kpi22,0) * 1000) ap_up_rate,
      nvl(t1.kpi6,0) * 1000 ap_down_flow,(nvl(t1.kpi34,0) * 1000) ap_down_rate,t1.kpi52 busy_apnum,
      t1.kpi53 idle_apnum,t1.kpi68 bad_apnum
      from results.result_#{guid}_0 t1")
    row = 1
    @school_quality.each do |quality|
      content = [quality.province_name,quality.ap_avg_relate,quality.ap_max_relate,quality.ap_max_online,
        quality.ap_avg_online,conv_to_percent(quality.ap_out_of_service),
        conv_to_percent(quality.ap_resource_avg_used),conv_to_percent(quality.ap_resource_max_used),
        conv_to_percent(quality.ap_relate_congest_rate),conv_to_percent(quality.ap_assocsucc_rate),
        two_decimal_digit(quality.ap_up_traffic),two_decimal_digit(quality.ap_up_rate),
        two_decimal_digit(quality.ap_down_flow),two_decimal_digit(quality.ap_down_rate),
        quality.busy_apnum,quality.idle_apnum,quality.bad_apnum]
      write_content(worksheet,content,row)
      row += 1
    end
  end

  def self.generate_district_perf(worksheet,guid)
    wlan_index_def = get_head
    header = ["省份","地市","区县"]
    wlan_index_def.each do |h|
      header << ((h.name_cn == "集团AP退服率" ? "AP退服率" : h.name_cn) + (h.name_unit.nil? ? '' : "(#{h.name_unit})"))
    end
    @traffic = {}
    if guid == '1318212765'
      ac_traffic = Rms::WlanTempPerfOutput.find_by_sql("select c.city company_name,round(sum(a.kpi43)/max(d.wired_traffic)*max(d.ac_traffic),2) ac_traffic
        from results.result_1318212765_0 a,device_infos b,mit_area_relation c,
        (select sum(t1.kpi113) ac_traffic,sum(t1.kpi43)+0.0000001 wired_traffic
        from results.result_1318212765_0 t1,device_infos t2,mit_area_relation t3
        where t1.town = t2.id(+)
        and t2.nodetype = 2
        and t2.nodecn = t3.district(+)
        and t3.city in ('城一','城二','城三','城四')) d
        where a.town = b.id(+)
        and b.nodetype = 2
        and b.nodecn = c.district(+)
        and c.city in ('城一','城二','城三','城四')
        group by c.city")
      ac_traffic.each do |traffic|
        @traffic[traffic.company_name] = traffic.ac_traffic
      end
      header << "分公司AC总流量(MB)"
    end
    write_header(worksheet,header)
    district_records = get_record(guid)
    row = 1
    district_records.each do |record|
      content = [record.provincecn,record.city_name,record.district_name,record.ac_num,record.port_num,record.ap_num,
        conv_to_percent(record.ap_available),record.apassocavg,conv_to_percent(record.ap_unavailable),record.apassocmax,
        record.onlineuseravg,record.onlineusermax,conv_to_percent(record.apusedmax),conv_to_percent(record.apusedavg),
        record.busy_acnum,record.busy_apnum,record.idle_apnum,record.bad_apnum,record.assocnum,record.assocfailed,
        record.reassocnum,record.reassocfailed,conv_to_percent(record.assocsucc_rate),record.refusednum,
        conv_to_percent(record.congest_rate),record.deauthnum,conv_to_percent(record.deauth_rate),
        two_decimal_digit(record.ac_traffic),two_decimal_digit(record.ac_rxbytes),
        two_decimal_digit(record.ac_txbytes),two_decimal_digit(record.wired_traffic),
        two_decimal_digit(record.wired_rxbytes),two_decimal_digit(record.wired_txbytes),
        two_decimal_digit(record.wired_rxrate_max),two_decimal_digit(record.wired_rxrate_avg),
        two_decimal_digit(record.wired_txrate_max),two_decimal_digit(record.wired_txrate_avg),
        two_decimal_digit(record.wired_rate_max),two_decimal_digit(record.wired_rate_avg),
        record.busy_portnum,record.bad_portnum,
        two_decimal_digit(record.wireless_traffic),two_decimal_digit(record.wireless_rxbytes),
        two_decimal_digit(record.wireless_txbytes),two_decimal_digit(record.wireless_rxrate_max),
        two_decimal_digit(record.wireless_rxrate_avg),two_decimal_digit(record.wireless_txrate_max),
        two_decimal_digit(record.wireless_txrate_avg),two_decimal_digit(record.wireless_rate_max),
        two_decimal_digit(record.wireless_rate_avg),record.challenge_total,record.challenge_suc,
        conv_to_percent(record.challenge_suc_rate),record.authreqtotal,record.authsuctotal,
        conv_to_percent(record.authsuc_rate),record.dhcpreqtimes,record.dhcpreqsuctimes,
        conv_to_percent(record.dhcpreqsuc_rate),record.login_total,record.login_suc,
        conv_to_percent(record.login_suc_rate),record.logout_total,record.logout_suc,
        conv_to_percent(record.logout_suc_rate),
        two_decimal_digit(record.available_hours),two_decimal_digit(record.unavailable_hours),
        two_decimal_digit(record.user_onlinetime),conv_to_percent(record.dhcp_rate),
        conv_to_percent(record.dhcp_maxrate),record.normaldrops,record.abnormaldrops,
        conv_to_percent(record.abnormaldrops_rate)]
      if guid == '1318212765'
        content << (@traffic[record.district_name].blank? ? '' : @traffic[record.district_name])
      end
      write_content(worksheet,content,row)
      row += 1
    end
  end

  def self.generate_province_perf(worksheet,netloc_gran,start_date,end_date,time_gran,guid)
    name_units = Rms::PerfType.index_units
    province_records = Procedure::WLAN_PERF_QRY.new.cq_report_analysis(netloc_gran, start_date, end_date, time_gran, guid)
    column = province_records.column_info[0...-1]
    result = province_records.results
    head = []
    content = []
    column.each do |col|
      head << ((col["name"] == '集团AP退服率' ? "AP退服率" : col["name"]) + (name_units[col["name"]].nil? ? "" : "(#{name_units[col["name"]]})"))
    end
    write_header(worksheet,head)
    row = 1
    result.each do |r|
      column.each do |col|
        content << (col["name"] == "日期" ? r[col["name"]].to_date : Procedure::DataFormater.format(col["name"], r[col["name"]]))
      end
      write_content(worksheet,content,1)
      row += 1
    end
  end

  def self.write_header(worksheet,header,border=nil)
    header.each_with_index do |h,i|
      worksheet.write(0, i, h,border)
    end
  end

  def self.write_content(worksheet,content,row)
    content.each_with_index do |c, i|
      worksheet.write(row, i, c)
    end
  end

  def self.conv_to_percent(data)
    '%.2f' %(data.nil? ? 0 : data * 100)
  end

  def self.two_decimal_digit(data)
    '%.2f' %(data.nil? ? 0 : data)
  end

  def self.get_head
    kpilist = [1,4,6,9,11,12,15,16,18,19,21,22,24,29,30,32,33,34,35,39,40,43,44,45,46,47,
      48,50,52,53,54,59,60,61,62,63,64,66,68,69,70,71,72,73,74,78,79,80,81,82,83,84,85,86,91,
      92,93,94,95,96,97,98,104,110,113,118,119,120,122,125]
    wlan_index_def = Rms::WlanIndexDef.find :all,
      :conditions => ["id in (?) and index_sys = ?",kpilist,1],
      :order => 'order_seq'
    return wlan_index_def
  end

  def self.get_record(guid)
    district_records = Rms::WlanTempPerfOutput.find_by_sql("
      select t2.provincecn,t2.citycn city_name,t3.city district_name,sum(t1.kpi4) ac_num,sum(t1.kpi44) port_num,
      sum(t1.kpi40) ap_num,avg(t1.kpi118) ap_available,avg(t1.kpi125) ap_unavailable,sum(t1.kpi30) apassocavg,
      sum(t1.kpi29) apassocmax,sum(t1.kpi66) onlineuseravg,sum(t1.kpi24) onlineusermax,sum(t1.kpi48) apusedmax,
      sum(t1.kpi9) apusedavg,sum(t1.kpi74) busy_acnum,sum(t1.kpi52) busy_apnum,sum(t1.kpi53) idle_apnum,
      sum(t1.kpi68) bad_apnum,sum(t1.kpi59) assocnum,sum(t1.kpi60) assocfailed,sum(t1.kpi61) reassocnum,
      sum(t1.kpi62) reassocfailed,sum(t1.kpi32) assocsucc_rate,sum(t1.kpi122) refusednum,sum(t1.kpi33) congest_rate,
      sum(t1.kpi63) deauthnum,sum(t1.kpi64) deauth_rate,sum(t1.kpi113) ac_traffic,sum(t1.kpi104) ac_rxbytes,
      sum(t1.kpi110) ac_txbytes,sum(t1.kpi43) wired_traffic,sum(t1.kpi12) wired_rxbytes,sum(t1.kpi19) wired_txbytes,
      sum(t1.kpi72) wired_rxrate_max,sum(t1.kpi15) wired_rxrate_avg,sum(t1.kpi73) wired_txrate_max,
      sum(t1.kpi16) wired_txrate_avg,sum(t1.kpi18) wired_rate_max,sum(t1.kpi21) wired_rate_avg,
      sum(t1.kpi119) busy_portnum,sum(t1.kpi120) bad_portnum,sum(t1.kpi11) wireless_traffic,sum(t1.kpi1) wireless_rxbytes,
      sum(t1.kpi6) wireless_txbytes,sum(t1.kpi47) wireless_rxrate_max,sum(t1.kpi22) wireless_rxrate_avg,
      sum(t1.kpi50) wireless_txrate_max,sum(t1.kpi34) wireless_txrate_avg,sum(t1.kpi35) wireless_rate_max,
      sum(t1.kpi39) wireless_rate_avg,sum(t1.kpi81) challenge_total,sum(t1.kpi82) challenge_suc,sum(t1.kpi83) challenge_suc_rate,
      sum(t1.kpi78) authreqtotal,sum(t1.kpi79) authsuctotal,sum(t1.kpi80) authsuc_rate,sum(t1.kpi69) dhcpreqtimes,
      sum(t1.kpi70) dhcpreqsuctimes,sum(t1.kpi71) dhcpreqsuc_rate,sum(t1.kpi84) login_total,sum(t1.kpi85) login_suc,
      sum(t1.kpi86) login_suc_rate,sum(t1.kpi93) logout_total,sum(t1.kpi94) logout_suc,sum(t1.kpi95) logout_suc_rate,
      sum(t1.kpi46) available_hours,sum(t1.kpi45) unavailable_hours,
      sum(t1.kpi54) user_onlinetime,sum(t1.kpi91) dhcp_rate,sum(t1.kpi92) dhcp_maxrate,
      sum(t1.kpi96) normaldrops,sum(t1.kpi97) abnormaldrops,sum(t1.kpi98) abnormaldrops_rate
      from results.result_#{guid}_0 t1,device_infos t2,mit_area_relation t3
      where t1.town = t2.id(+)
      and t2.nodetype = 2
      and t2.nodecn = t3.district(+)
      group by t2.provincecn,t2.citycn,t3.city")
    return district_records
  end

  def self.attach_sort_option(query_cons,sort)
    query_cons[:order] = "#{sort[:name]} #{sort[:direction]}"
  end

end
