class Rms::WlanAcPerf
  include HourlyImport
  @@sqlldr_seq = [:acdn,:sampletime,:radiusip,:ac_status,:pingok,:pingtimeout,:pingok_count,:pingall_count,:cpuper,:memper,
    :uplink_bandwidth,:ifoutoctets,:ifoutoctetsmax,:ifinoctets,:ifinoctetsmax,
    :ifindiscards,:ifinucastpkts,:ifoutucastpkts,:dhcpreqtimes,:dhcpreqsuctimes,:sessions,:authtotals,:maxsessions,:normaldrops,
    :abnormaldrops,:authreqtotals,:authsuctotals,:accreqnum,:accsucnum,:radiusreqpkts,:radiusreppkts,:leavereqpkts,:leavereppkts,
    :radiuavgdelay,:challenge_total,:challenge_suc,:login_total,:login_suc,:logout_total,:logout_suc,:ip_using,:dhcp_rate,
    :delaymax,:delaymin,:delayper,:ping_loss]
  
  class << self
    def write_sqlldr_file(ac_perfs)
      FileUtils.mkdir_p("#{RAILS_ROOT}/tmp/hourly_import")
      file = File.new("#{RAILS_ROOT}/tmp/hourly_import/ac_perf_import_#{Time.now.strftime("%H")}.ctl", "w")
      begin
        file << "OPTIONS(ERRORS=100000)\n"
        file << "Load DATA\nINFILE *\n"
        file << "TRUNCATE INTO TABLE WLAN_AC_PERF_IMPORT\n"
        file << "Fields terminated by \"|\"\n"
        file << "TRAILING NULLCOLS\n"        
        file << "(#{@@sqlldr_seq.collect{|s| (s == :sampletime) ? "#{s.to_s.upcase} Date 'yyyy-mm-dd HH24:mi:ss'" : s.to_s.upcase }.join(",")})\n"
      file << "BEGINDATA\n"
      ac_perfs.each do |ac_perf| file << ac_perf.to_sqlldr + "\n" end
    ensure
      file.close
    end
  end
end
end
