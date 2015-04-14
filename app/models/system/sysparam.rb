class System::Sysparam < ActiveRecord::Base
  set_table_name "sysparams"
  after_save :rms_sysparam , :if => :alarm_repair?

  validate :validation_for_project_status_with_ap_state

  def before_update
    if param_name == "自动刷新"  
      errors.add("自动刷新时间必须在3分钟以上") if param_value.to_i < 3
    end
  end

  def alarm_repair?
    self.param_code == 'alarm_repair'
  end
  
  def rms_sysparam
    rms_param = Rms::Sysparam.find_by_param_code('ALARM_PERIOD')
    rms_param.update_attributes(:param_value => self.param_value.to_i * 60 )
  end

  def self.last_time
    find :first, :select => "param_value", :conditions => ["param_code = 'alarm_time'"]
  end

  def self.auto_refresh
    database_time = find_by_param_code("auto_reload")
    if database_time.nil?
      5 * 60
    else
      database_time = database_time.param_value.to_i
      if database_time == 0
        5 * 60 
      elsif database_time < 3
        3 * 60 
      else
        database_time * 60 
      end
    end
  end

  def validation_for_project_status_with_ap_state
    if param_code =~ /^project_status=/
      errors.add(:param_value, "AP状态值应该在0至3之间。") unless %w(0 1 2 3).include?(param_value)
    end
  end

  class << self
    def ap_state(project_status)
      setting = find_by_param_code("project_status=#{project_status}")
      setting.nil? ? project_status : setting.param_value.to_i
    end
    
    def site_collect_rule_of_ap
      setting = find_by_param_code("site_collect_rule_of_ap")
      rule = CollectRule.find(:all, :conditions => "id = #{setting.param_value.to_i}")
      setting.nil? ? "" : (rule.blank? ? "" : setting.param_value.to_i)
    end
  end
end
