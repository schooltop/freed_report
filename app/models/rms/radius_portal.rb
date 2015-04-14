class Rms::RadiusPortal < External
  set_table_name "WLAN_RADIUS_REPORT"
  set_sequence_name "wlan_seq_infos"
  
  class << self
    def query_by_user(params, sort, page)
      options = {}
      attach_group_by(params, options)
      paginate :all, options.merge({:page => page, :per_page => 30})
    end
    
    def attach_date_range(params, options)
      options[:conditions] = "sample_date > to_date('#{params[:start_date]}', 'yyyy-mm-dd') and sample_date < to_date('#{params[:end_date]}', 'yyyy-mm-dd')"
    end
    
    def attach_group_by(params, options)
      select = []
      group = []
      case params[:time_gran].to_i
        when 0
        group << "to_char(sample_date,'yyyy')"
        select << "to_char(sample_date,'yyyy') year"
        when 1
        group << "to_char(sample_date,'yyyy-mm')"
        select << "to_char(sample_date,'yyyy-mm') month"
        when 2
        group << "to_char(sample_date,'yyyy-mm-dd')"
        select << "to_char(sample_date,'yyyy-mm-dd') sample_date"
        when 3
        group << "sample_date, sample_hour"
        select << "sample_date, sample_hour"
      end
      case params[:area_gran].to_i
        when 0
          group << "province"
          select << "province"
        when 1
          group << "province,city"
          select << "province,city"
        when 2
          group << "province,city,ac_ip,ac"
          select << "province,city,ac_ip,ac"
      end
      select.concat sum_select
      options[:select] = select.join(",")
      options[:group] = group.join(",")
    end
    
    def sum_select
      select = []
      select << "sum(auth_total) auth_total"
      select << "sum(online_auth_total) online_auth_total"
      select << "sum(online_auth_success_total) online_auth_success_total"
      select << "sum(online_auth_success_total) / (sum(online_auth_total) + 0.00001) online_auth_success_ratio"
      select << "sum(offline_auth_total) offline_auth_total"
      select << "sum(offline_auth_success_total) offline_auth_success_total"
      select << "sum(offline_auth_success_total) / (sum(offline_auth_total) + 0.00001) offline_auth_success_ratio"
      select << "sum(chall_interact_total) chall_interact_total"
      select << "sum(chall_interact_success_total) chall_interact_success_total"
      select << "sum(chall_interact_success_total) / (sum(chall_interact_total) + 0.00001) chall_interact_success_ratio"
      return select
    end
    
  end
end