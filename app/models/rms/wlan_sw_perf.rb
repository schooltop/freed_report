class Rms::WlanSwPerf
  include HourlyImport
  @@sqlldr_seq = [:swdn,:sampletime,:pingok,:pingtimeout,:cpuper,:delayper]
  
  class << self
    def write_sqlldr_file(sw_perfs)
      FileUtils.mkdir_p("#{RAILS_ROOT}/tmp/hourly_import")
      file = File.new("#{RAILS_ROOT}/tmp/hourly_import/sw_perf_import_#{Time.now.strftime("%H")}.ctl", "w")
      begin
        file << "OPTIONS(ERRORS=100000)\n"
        file << "Load DATA\nINFILE *\n"
        file << "TRUNCATE INTO TABLE WLAN_SW_PERF_IMPORT\n"
        file << "Fields terminated by \"|\"\n"
        file << "TRAILING NULLCOLS\n"
        file << "(#{@@sqlldr_seq.collect{|s| (s == :sampletime) ? "#{s.to_s.upcase} Date 'yyyy-mm-dd HH24:mi:ss'" : s.to_s.upcase }.join(",")})\n"
      file << "BEGINDATA\n"
      sw_perfs.each do |sw_perf| file << sw_perf.to_sqlldr + "\n" end
    ensure
      file.close
    end
  end
end
end
