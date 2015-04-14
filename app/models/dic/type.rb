class Dic::Type < ActiveRecord::Base
  set_table_name 'dic_types'
  
  has_many :dic_codes, :class_name => "Dic::Code", :foreign_key => "type_id", :conditions => { :is_valid => true }
    
  def self.device_type
    find(:first, :conditions => ["type_name = 'device_type'"])
  end
  #直放站种类
  def self.repeater_category
    find(:first, :conditions => ["type_name = 'repeater_category'"])
  end
  #直放站廠商
  def self.repeater_manu
    find(:first, :conditions => ["type_name = 'repeater_manu'"])
  end
  # 直放站型號
  def self.repeater_kind
    find(:first, :conditions => ["type_name = 'repeater_kind'"])
  end
  #直放站安装方式
  def self.install_type
    find(:first, :conditions => ["type_name = 'install_type'"])
  end
  #AP设备类型
  def self.ap_type
    find(:first, :conditions => ["type_name = 'ap_type'"])
  end
  #设备供应商
  def self.device_vendor
    find(:first, :conditions => ["type_name = 'device_manu'"])
  end
  #热点热点类型
  def self.port_type
    find(:first, :conditions => ["type_name = 'port_type'"])
  end
  #热点类型
  #hotspot type
  def self.site_type
    find(:first, :conditions => ["type_name = 'port_type'"])
  end

  #  热点小类
  def self.sub_site_type
    find(:first, :conditions => ["type_name = 'sub_port_type'"])
  end

  # 热点等级
  def self.site_level
    find(:first, :conditions => ["type_name = 'site_level'"])
  end
  
  def self.find_site_by_site_level(level)
    Dic::Code.find(:first, :conditions => ["code_label = '#{level}' and type_id = 49"])
  end

  def self.find_site_type_by_port_type(type)
    Dic::Code.find(:first, :conditions => ["code_label = '#{type}' and type_id = 4"] )
  end

  def self.find_site_type_by_sub_type(sub_type,port_type)
    Dic::Code.find(:first, :conditions => ["code_label = ? and parent_id = ?", sub_type,port_type])
  end
  
  #行政区域
  def self.district
    find(:first, :conditions => ["type_name = 'district'"])
  end
  
  #支持业务
  def self.support_biz
    find(:first, :conditions => ["type_name = 'support_biz'"])
  end
  
  #工程阶段
  def self.phase
    find(:first, :conditions => ["type_name ='phase'"])
  end
  
  #文档齐全
  def self.document
    find(:first, :conditions => ["type_name ='document'"])
  end
  
  #传输类型
  def self.transfer_type
    find(:first, :conditions => ["type_name = 'transfer_type'"])
  end
  
  #供电方式
  def self.power_type
    find(:first, :conditions => ["type_name = 'power_type'"])
  end
  
  #AP等级
  def self.ap_level
    find(:first, :conditions => ["type_name = 'ap_level'"])
  end
  
  #使用状态
  def self.ap_state
    find(:first, :conditions => ["type_name = 'ap_state'"])
  end
  
  #交换机型号
  def self.sw_type
    find(:first, :conditions => ["type_name = 'sw_type'"])
  end
  
  #交换机使用状态
  def self.sw_state
    find(:first, :conditions => ["type_name = 'sw_state'"])
  end

  #网络状态
  def self.net_state
    find(:first, :conditions => ["type_name = 'net_state'"])
  end

  #产品状态
  def self.production_state
    find(:first, :conditions => ["type_name = 'productionState'"])
  end

  #管理状态
  def self.managed_state
    find(:first, :conditions => ["type_name = 'managedState'"])
  end

  #检测状态
  def self.monitor_state
    find(:first, :conditions => ["type_name = 'monitorState'"])
  end

  #AC型号
  def self.ac_type
    find(:first, :conditions => ["type_name ='ac_type'"])
  end

  #def self.device_type
  #  find(:all, :conditions => ["type_name in ('ap_type','sw_type','ac_type','port_type')"])
  #end

  #覆盖范围
  def self.fg_type
    find(:first, :conditions => ["type_name ='fg_type'"])
  end

  #AP覆盖方式
  def self.cover_type
    find(:first, :conditions => ["type_name = 'cover_type'"])
  end

  #布放方式
  def self.layout_type
    find(:first, :conditions => ["type_name = 'layout_type'"] )
  end

  #建设方式
  def self.construct_type
     find(:first, :conditions => ["type_name = 'construct_type'"] )
  end

  #热点覆盖方式
  def self.site_cover_type
    find(:first, :conditions => ["type_name = 'site_cover_type'"] )
  end

  #  def self.method_missing(method_id, *arguments, &block)
  ##    super unless self.column_names.include?(method_id.to_s)
  #    self.class_eval  %{
  #      def self.#{method_id}(*args)
  #         find(:first,:conditions => "type_name = '#{method_id}'")
  #      end
  #    }, __FILE__, __LINE__
  #    send(method_id, *arguments, &block)
  #  end
end
