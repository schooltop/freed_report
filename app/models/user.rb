require 'digest/sha1'

class User < ActiveRecord::Base

  set_table_name "users"
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  belongs_to :domain
  belongs_to :role, :class_name => "System::Role"
  has_many :fault_filter_conditions, :dependent => :destroy
  has_many :portal_contents
  has_many :export_files, :order => "id DESC"

  after_update :clean_protal_contents

  preference :dashboard_show, :string, :default => "events_by_severity,events_by_severity_and_type,sites_by_fault,devices_by_severity,ap_traffic_top10,ap_peak_top10,ap_relate_top10,wifi_muc,wireless_traffic,ap_fault_rate,acceptance_criteria,network_state,crucial_perfs,devices_by_avail,devices_by_rate,district_by_rate,network_element_change,supplies,ap_collect,resource_count_by_area,ap_num_by_port_type,,traffic_user_num_by_port_type"
  preference :dashboard_mini, :string, :default => ""
  preference :dashboard_sort, :string, :default => "events_by_severity,events_by_severity_and_type,sites_by_fault,devices_by_severity,ap_traffic_top10,network_element_change,wifi_muc,wireless_traffic,ap_fault_rate,acceptance_criteria,crucial_perfs,|,ap_peak_top10,ap_relate_top10,network_state,devices_by_avail,devices_by_rate,district_by_rate,supplies,ap_collect,resource_count_by_area,ap_num_by_port_type,,traffic_user_num_by_port_type"

  validates_presence_of     :login,   :message => "登陆名不能为空"
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,   :message => "用户名已经存在"
  validates_format_of       :login,    :with => Authentication.login_regex, :message => "用户名格式错误"

  validates_presence_of     :name,     :message => "真实姓名不能为空"
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => "真实姓名格式错误"
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email,   :message => "邮箱不能为空"
  validates_length_of       :email,    :within => 6..100, :message => "邮箱至少是包含'@和.'的六位字符" #r@a.wk
#  validates_uniqueness_of   :email,    :message => "邮箱已经被用"
  validates_format_of       :email,    :with => Authentication.email_regex, :message => "邮箱格式错误"

  validates_presence_of     :role_id, :message => "角色不能为空"
  validates_presence_of     :domain_id, :message => "域名不能为空"

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation,:role_id,:domain_id,:department,:telephone,
    :mobile, :memo, :status

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => ['login = ?', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.root
    find_by_login('root')
  end
  
  def is_province_level_user?
    cityid == 0
  end
  
  def cityid
    Area.find_by_site_dn(domain.base).cityid
  end

  def city
    Area.find cityid unless cityid == 0
  end

  def site_type
    Area.find_by_site_dn(domain.base).site_type
  end

  def collect_rules
    CollectRule.find(:all, :conditions => "created_user=1 or created_user =#{id} or created_user is null or #{id}=1")
  end

  def clean_protal_contents
    if domain_id_changed?
      PortalContent.destroy_all(:user_id => id)
    end
  end

  class << self
    def current=(language)
      Thread.current["current_user"] = language
    end

    def current
      Thread.current["current_user"] || nil
    end 
  end
end
