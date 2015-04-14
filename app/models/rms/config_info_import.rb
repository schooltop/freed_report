class Rms::ConfigInfoImport
    include HourlyImport
    @@sqlldr_seq = [:cityid,:nodetype,:nodedn,:nodecn,:provincedn,:provincecn,:order_seq,
    :citydn,:citycn,:towndn,:towncn,:portdn,:portcn,:port_type,:enterprise_id,
    :supply_id,:uplink_bandwidth,:longitude,:latitude,:address,:bsid,:device_name,
    :sub_port_type,:open_type,:ap_count,:cover_range,:sysdesc,:buildingdn,:buildingcn,
    :floordn,:floorcn,:acdn,:accn,:apen,:ip,:ap_fit,:device_state,:device_type,:device_manu,
    :nas_id,:soft_ver,:radius_ip,:ip_start,:ip_stop,:ippool_name,:swdn,:swcn,:swportdn,
    :swportcn,:power,:mac,:ssids,:channel,:radio_model,:port_ac,:supporter_dep,:supporter,
    :supporter_phone,:maxaplimit,:ap_prj_count,:created_at,:college_id,:project_state,
    :site_level,:starbuck_id]
    
    class << self
      def write_sqlldr_file(config_infos)
        FileUtils.mkdir_p("#{RAILS_ROOT}/tmp/hourly_import")
        file = File.new("#{RAILS_ROOT}/tmp/hourly_import/mit_data_import_#{Time.now.strftime("%H")}.ctl", "w")
      begin
        file << "OPTIONS(ERRORS=100000)\n"
        file << "Load DATA\nINFILE *\n"
        file << "TRUNCATE INTO TABLE CONFIG_INFOS_TEMP\n"
        file << "Fields terminated by \"|\"\n"
        file << "TRAILING NULLCOLS\n"
        file << "(#{@@sqlldr_seq.collect{|s| (s == :sampletime || s == :created_at) ? "#{s.to_s.upcase} Date 'yyyy-mm-dd HH24:mi:ss'" : s.to_s.upcase }.join(",")})\n"
        file << "BEGINDATA\n"
        config_infos.each do |config_info| file << config_info.to_sqlldr + "\n" end
      ensure
        file.close
      end
    end
  end
end