require "hourly_import"
class Rms::WlanApPerf
  include HourlyImport
  
  @@sqlldr_seq = [:apdn,:sampletime,:pingok,:pingtimeout,:snmpok,:snmptimeout,:pingok_count,
          :pingall_count,:snmpok_count,:snmpall_count,:assocnum,:assocsuccnum,:reassocnum,:reassocsuccnum,:refusednum,:deauthnum,:rxbytestotal,
          :rxbytestotalmax,:rxpacketstotal,:rxpacketsdropped,:rxpacketsunicast,:rxpacketserror,:ifinavgsignal,:ifinhighsignal,:ifinlowsignal,
          :txbytestotal,:txbytestotalmax,:txpacketstotal,:txpacketsdropped,:txpacketsunicast,:txpacketserror,:ifframeretryrate,
          :apassocnum,:aponlinenum,:ifinoctets,:ifinoctetsmax,:ifinpkts,:ifindiscards,:ifinucastpkts,:ifinerrors,:ifoutoctets,
          :ifoutoctetsmax,:ifoutpkts,:ifoutdiscards,:ifoutucastpkts,:ifouterrors,:delayper,:cpuper,:memper]
    
  class << self
    def write_sqlldr_file(ap_perfs)
      FileUtils.mkdir_p("#{RAILS_ROOT}/tmp/hourly_import")
      file = File.new("#{RAILS_ROOT}/tmp/hourly_import/ap_perf_import_#{Time.now.strftime("%H")}.ctl", "w")
      begin
        file << "OPTIONS(ERRORS=100000)\n"
        file << "Load DATA\nINFILE *\n"
        file << "TRUNCATE INTO TABLE WLAN_AP_PERF_IMPORT\n"
        file << "Fields terminated by \"|\"\n"
        file << "TRAILING NULLCOLS\n"        
        file << "(#{@@sqlldr_seq.collect{|s| (s == :sampletime) ? "#{s.to_s.upcase} Date 'yyyy-mm-dd HH24:mi:ss'" : s.to_s.upcase }.join(",")})\n"
        file << "BEGINDATA\n"
        ap_perfs.each do |ap_perf| file << ap_perf.to_sqlldr + "\n" end
      ensure
        file.close
      end
      
    end
  end
end
