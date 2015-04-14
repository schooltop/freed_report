class Logm::SecurityLog < ActiveRecord::Base
  set_table_name "logm_securities"

  class << self
    def export_column_names
      ['user_name','terminal_ip','host_name','security_action','result','details','created_at']
    end
  end
end