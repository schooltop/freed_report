class Logm::OperationLog < ActiveRecord::Base
  set_table_name "logm_operations"
  
  def to_pasm(operation_type)
    LogEntity.new(self, operation_type)
  end

  class << self
    def export_column_names
      ['user_name','terminal_ip','module_name','action','result','details','created_at']
    end
  end
end