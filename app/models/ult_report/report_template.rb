class UltReport::ReportTemplate < External
  set_sequence_name "wlan_seq_config"
  set_table_name "ULTRA_PRO_PERF_TEMPLATE"
  has_many :chart_sets, :class_name => "UltReport::ChartSet", :foreign_key => 'template_id', :order => "id"
  has_many :report_template_users, :class_name => "UltReport::ReportTemplateUser", :foreign_key => "template_id"
  belongs_to :category, :class_name => "Rms::Category", :foreign_key => "category_id", :include => :templates
  before_save :adjust_attributes
  before_save :adjust_attributes_when_case, :if => :is_case_template?
  validates_presence_of :report_name, :message => "报表名称不允许为空"
  validates_presence_of :time_gran, :message => "时间粒度不允许为空", :if => :if_is_resource_template?
  validates_presence_of :netloc_gran, :message => "区域粒度不允许为空"
  validates_uniqueness_of :report_name, :message => "报表名称已经存在"
  validates_presence_of :busytime,  :message => "忙时选项不能为空" ,:if => :is_perf_or_case?
  validates_presence_of :hourlist,  :missage => "统计时段不能为空", :if => :if_is_hourlist?
  validates_presence_of :time_define,  :missage => "时间范围不能为空", :unless => :if_cate_gory_id_is_blank_and_group_type_is_common? 
  validates_length_of :report_name, :maximum => 50, :message => "报表名称过长"
  validates_presence_of :netloc, :message => "请选择一个专案树", :if => :is_case_template?
  validates_presence_of :busi_type, :message => "请选择集团报表的类型", :if => :is_cmcc_template?
  validates_presence_of :category_id, :message => "请选择所属分类", :if => :is_common_template?
  #validates_presence_of :busi_type, :message => "请选择集团报表的类型", :if => :if_group_type_is_busi?
  #
  named_scope :cmcc_rts,                :order => "report_name", :conditions => { :group_type => 1 } 
  named_scope :cmcc_resource_templates, :order => "report_name", :conditions => { :group_type => 1, :report_type => 4}
  named_scope :cmcc_perf_templates,     :order => "report_name", :conditions => { :group_type => 1, :report_type => 1, :busi_type => 1}
  named_scope :cmcc_busi_templates,     :order => "report_name", :conditions => { :group_type => 1, :report_type => 1, :busi_type => 2}

  def crt_type
    types = self.class.load_cmcc_report_template_types
    if group_type == 1 && report_type == 4
      types[0]
    elsif group_type ==1 && report_type ==1 && busi_type == 1
      types[1]
    elsif group_type ==1 && report_type ==1 && busi_type == 2
      types[2]
    end
  end

  def self.load_cmcc_report_template_types
    types = [] 
    types << Rms::BusiType.new(:id => 0, :name => "资源报表", :type_name => "cmcc_resource_templates", :value => "report_type=4 and group_type=1")
    types << Rms::BusiType.new(:id => 1, :name => "性能报表", :type_name => "cmcc_perf_templates",     :value => "report_type=1 and group_type=1 and busi_type=1")
    types << Rms::BusiType.new(:id => 2, :name => "业务报表", :type_name => "cmcc_busi_templates",     :value => "report_type=1 and group_type=1 and busi_type=2")
  end
  
  def self.cmcc_report_templates(busi_type = 1)
    find(:all, :conditions => {:group_type => 1, :busi_type => busi_type})
  end

  def to_json(options = {})
    super(options)
  end
  
  def get_time_range
    now = Date.current
    case time_define
    when 1
      [now.strftime("%Y-%m-%d"), now.strftime("%Y-%m-%d")]
    when 2
      [(now - 1.days).strftime("%Y-%m-%d"), (now - 1.days).strftime("%Y-%m-%d")]
    when 3
      [now.at_beginning_of_week.strftime("%Y-%m-%d"), now.at_end_of_week.strftime("%Y-%m-%d")]
    when 4
      [(now - 1.weeks).at_beginning_of_week.strftime("%Y-%m-%d"), (now - 1.weeks).at_end_of_week.strftime("%Y-%m-%d")]
    when 5
      [now.at_beginning_of_month.strftime("%Y-%m-%d"), now.at_end_of_month.strftime("%Y-%m-%d")]
    when 6
      [(now - 1.months).at_beginning_of_month.strftime("%Y-%m-%d"), (now - 1.months).at_end_of_month.strftime("%Y-%m-%d")]
    end
  end
  
  def apply_default_value(perf_template)
    #    unless perf_template.nil?
    #      @attributes["dic_group_con"] = perf_template[:dic_group_con] ||= {:device_manu => [], :device_type => []}
    #      self.chart_sets = perf_template[:chart_sets].collect{|chart_set|
    #        Rms::ChartSet.new({:chart_seq => chart_set.chart_seq, :chart_name => chart_set.chart_name,
    #            :chart_type => chart_set.chart_type, :x_col => chart_set.x_col, :group_col => chart_set.group_col})
    #      } unless perf_template[:chart_sets].nil?
    #      self.report_template_users = perf_template[:report_template_users].collect{|user_id|
    #        UltReport::ReportTemplateUser.new({:user_id => user_id})
    #      }unless perf_template[:report_template_users].nil?
    #    else
    #      @attributes["dic_group_con"] ||= {:device_manu => [], :device_type => []}
    #    end
    @attributes["kpilist"] ||= []
    @attributes["dic_group"] ||= []
    @attributes["top_n"] ||= 100
    
    if @attributes['group_original'] and @attributes['group_original'].index('porttype')
      if @attributes['dic_group'].is_a?(String)
        @attributes['dic_group'] = (@attributes['dic_group'].split(',') << 'porttype').join(',')
      else
        @attributes['dic_group'] << 'porttype'
      end
    end
  end
  
  def create_chart_set(charts)
    return if charts.nil?
    charts.each { |chart|
      chart_sets.create(UltReport::ReportTemplateSet.adjust_attributes(chart))
    }
  end
  
  def create_template_user(current_user, users)
    report_template_users.create({:user_id => current_user.id, :cityid => current_user.cityid})  unless current_user.login == 'root'
    return if users.nil?
    users.each { |user|
      report_template_users.create({:user_id => user, :cityid => current_user.cityid})
    }
  end
  
  def apply_creator(user)
    self.userid = user.id
    self.cityid = user.cityid
  end

  def build_netloc_for_common_and_cmcc user
    self.netloc = UltReport::ReportTemplate.get_netloc(user.domain.base)
    self.apply_dic_group_for_common_and_cmcc
  end

  def apply_dic_group_for_common_and_cmcc
    return  unless self.report_type.to_i == 1
    unless group_original.nil?
      conditions = []
      group_original.split("\;").each do |original|
        otmp = original.split("=")
        conditions << ("(#{otmp[0]} in (#{otmp[1]}))")
      end
      netloc = []
      netloc.push self.netloc if !self.netloc.nil? && !self.netloc.empty?
      netloc.push "#{conditions.join(" and ")}" unless conditions.empty?
      self.netloc = netloc.join(" and ")
    else
      self.netloc = self.netloc if !self.netloc.nil? && !self.netloc.empty?
    end
  end

  def self.get_netloc(base)
    base = DeviceInfo.find_by_nodedn base
    if !base.nil?
      if base.nodetype == 1
        return "(cityid = #{base.id})"
      elsif base.nodetype == 2
        return "(town = #{base.id})"
      end
    end
    return ""
  end
  
  def apply_dic_group_conditions(dic_group_con)
    return  unless self.report_type.to_i == 1
    unless dic_group_con.nil?
      conditions = []
      dic_group_con.each { |k, v|
        if v and v != "全部" and v.first != "全部"
          v = v.join(',') if v.is_a?(Array)
          conditions << ("(#{k} in (#{v}))")
        end
      }
      netloc = []
      netloc.push "(#{self.netloc})" if !self.netloc.nil? && !self.netloc.empty?
      netloc.push "#{conditions.join(" and ")}" unless conditions.empty?
      self.netloc = netloc.join(" and ")
    else
      self.netloc = "(#{self.netloc})" if !self.netloc.nil? && !self.netloc.empty?
    end
  end
  
  def adjust_attributes_when_case
    self.netloc_original = self.netloc
  end
  
  def adjust_attributes
    self.netloc = nil if self.netloc.nil? || self.netloc.include?("province")
    self.hourlist = self.hourlist.join(",") unless self.hourlist.nil?
    #参数值为Array,数据库的值为String,update时不需要数据库值
    if !self.dic_group.nil?  and self.dic_group.is_a?(Array)
      self.dic_group = self.dic_group.delete_if { |dic| dic == "porttype" }
      self.dic_group = self.dic_group.uniq.join(",")
    end
    self.kpilist = self.kpilist.join(",") unless self.kpilist.nil?
    if !self.netloc.nil? && !self.netloc.empty?
      netloc = self.netloc.split(" and ")[0]
      netloc = netloc.gsub(/[()]/,'')
      self.netloc_original = netloc.split(" or ").collect{|loc|
        loc.split("=")[1]
      }.join(",")
    end
    if !self.group_original.nil? && !self.group_original.empty? && self.group_original.is_a?(Hash)
      group_original = []
      self.group_original.each_pair { |key, value|
        next if value == "全部" || value.first == "全部"
        value = value.join(",") if value.is_a? Array
        group_original.push("#{key}=#{value}")        
      }
      self.group_original = group_original.join(";")
    end
    if !self.index_filter.blank? && self.index_filter.is_a?(Hash)
      index_filter = []
      self.index_filter.each_pair{ |index, value|
        index_filter << "nvl(#{index},0) #{value["op"]} #{value["value"].split.join('')} " if !value["op"].blank? && !value["value"].blank?
      }
      self.index_filter = index_filter.join(" and ")
    end
  end
  
  def is_case_template?
    report_type == 3
  end

  def is_cmcc_template?
    report_type == 1 && group_type == 1 && busi_type.nil? 
  end

  def is_common_template?
    (report_type == 1 || report_type == 4) && group_type == 2 && category_id.nil? 
  end
  
  def is_perf_or_case?
    report_type == 1 or report_type == 3
  end
  
  def if_is_resource_template?
    report_type == 1 or report_type == 2 or report_type == 3
  end
  
  def if_is_hourlist?
    self.busytime == -3
  end

  def if_cate_gory_id_is_blank_and_group_type_is_common?
    self.category_id.blank? && self.group_type == 3 
  end

  def if_group_type_is_busi?
    group_type == 1
  end

  class << self
    def clear_associations(ids)
      ids = ids.split(",") unless ids.is_a? Array
      UltReport::ReportTemplateSet.delete_all("TEMPLATE_ID in (#{ids.join(",")})")
      UltReport::ReportTemplateUser.delete_all("TEMPLATE_ID in (#{ids.join(",")})")
    end
    def new_template(attrs)
      new attrs.merge!({:report_standard => 1, :index_sys => 1, :time_type => 1})
    end
    
    def index_type(netgran)
      types = Rms::PerfType.find(:all, :conditions=>get_index_by_netgran(netgran) + " and index_sys = 1 and is_custom = 0", :order=>'order_seq,name_cn')
      types.collect{|u| { :id => u.id, :name => u.name_cn, :ename => u.name_en, :unit => u.name_unit } } if types && types.size > 0
    end
    
    def domains_tree(user,parent,select_id,level)
      path_id = []
      domain_base = user.domain.base
      root = Deviceinfo.find_by_nodedn(domain_base)
      if select_id and !select_id.empty?
        select_id.split(',').each do |id|
          selecteds = Deviceinfo.find(:all,:select => 'city,town,port',:conditions=>"id in #{id}")
          single_path_id = selecteds.collect { |selected| [selected.city, selected.town, selected.port] }
          single_path_id = single_path_id.flatten.compact.uniq
          single_path_id.delete(id.to_i)
          path_id += single_path_id 
        end
      end
      select_id = select_id ||''
      if parent.to_i == -1  
        root_nodes = {:title => root.nodecn, :key => root.id, :level => root.nodetype, :expand =>true,
          :select => select_id.split(',').include?(root.id.to_s), :level_desc => get_level_desc(root.nodetype)}
        root_nodes[:select] = true if select_id.empty? and root.cityid == 0 #默认全省
        root_nodes[:children] = children(root.id,path_id,select_id.split(','), root.nodetype)
        return root_nodes
      end
      return children(parent, path_id,select_id.split(','), level)
    end
    
    def case_tree(user,parent_id,netloc='')
      netloc = netloc.split(',') unless netloc.is_a?(Array)
      if  user.id == 1 or parent_id.to_i == -1
        case_groups = Rms::CaseGroup.find(:all,:conditions=>"parent_id = #{parent_id}")
      else
        case_groups = Rms::CaseGroup.find(:all,
          :joins =>"left join wlan_case_users on wlan_case_groups.id = wlan_case_users.case_id",
          :conditions => "wlan_case_users.user_id = '#{user.id}' and wlan_case_groups.parent_id = #{parent_id}")
      end
      data = []
      if case_groups
        case_groups.each do |case_group|
          if Rms::CaseGroup.find_by_parent_id(case_group.id)
            data << {"leaf" => false,"title" =>case_group.case_name,"key" => case_group.id.to_s,
              "expand"=>true,"children" => case_tree(user,case_group.id,netloc),
              "select" => netloc.include?(case_group.id.to_s)? true:netloc.empty?? case_group.id==0:false }#默认选中专案树
          else
            data << {"leaf" => true,"title" =>case_group.case_name,"key" => case_group.id.to_s,"expand"=>true,"select" => netloc.include?(case_group.id.to_s)}
          end
        end
        data
      end
    end
    
    private
    def get_index_by_netgran(netgran)
      case netgran.to_i
      when 0..2
        return "is_town = 1"
      when 3..4
        return "is_port = 1"
      when 5
        return "is_port = 1"
      when 6..7
        return "is_floor = 1"
      when 8
        return "is_ac = 1"
      when  9
        return "is_sw = 1"
      when 10
        return "is_swport = 1"
      when 11
        return "is_ap = 1"
      else
        return "is_ap = 1"
      end
    end
    def get_level_desc(level)
      case level.to_i
      when 0
        "province"
      when 1
        "cityid"
      when 2
        "town"
      when 5
        "port"
      end
    end
    def children(parent, path,select, level)
      case level.to_i
      when 0:
          return wrap_nodes(Deviceinfo.all(:conditions => ["nodetype = ?", 1], :order=>"order_seq"), path,select,1, "cityid")
      when 1:
          return wrap_nodes(Deviceinfo.all(:conditions => ["nodetype = ? and city = ?", 2, parent], :order=>"order_seq"),path, select, 2, "town")
      when 2:
          return wrap_nodes(Deviceinfo.all(:conditions => ["nodetype = ? and town = ?", 5, parent], :order=>"nodecn asc"),path, select, 3, "port")
      else
        return []
      end
    end
    def wrap_nodes(parent, path,select, next_level, level_desc)
      parent.collect { |device|
        node = {:title => device.nodecn, :key => device.id, :level_desc => level_desc, :level => next_level,
          :select => select.include?(device.id.to_s)
        }
        if path.include?(device.id) 
          node.update({ :expand => true,:children => children(device.id,path, select, next_level)})
        else
          node.update({:isLazy => true})
        end
        node
      }
    end
  end
end
