require "hourly_import"
class Rms::WlanSsidPerf
  include HourlyImport
  @@sqlldr_seq = [:ssiddn,:sampletime,:rxbytestotal,:rxpacketstotal,:txpacketstotal]
  
  class << self
    def write_sqlldr_file(ssid_perfs)
      FileUtils.mkdir_p("#{RAILS_ROOT}/tmp/hourly_import")
      file = File.new("#{RAILS_ROOT}/tmp/hourly_import/ssid_perf_import_#{Time.now.strftime("%H")}.ctl", "w")
      begin
        file << "OPTIONS(ERRORS=100000)\n"
        file << "Load DATA\nINFILE *\n"
        file << "TRUNCATE INTO TABLE WLAN_SSID_PERF_IMPORT\n"
        file << "Fields terminated by \"|\"\n"
        file << "TRAILING NULLCOLS\n"        
        file << "(#{@@sqlldr_seq.collect{|s| (s == :sampletime) ? "#{s.to_s.upcase} Date 'yyyy-mm-dd HH24:mi:ss'" : s.to_s.upcase }.join(",")})\n"
      file << "BEGINDATA\n"
      ssid_perfs.each do |ssid_perf| file << ssid_perf.to_sqlldr + "\n" end
    ensure
      file.close
    end
  end
end
end
