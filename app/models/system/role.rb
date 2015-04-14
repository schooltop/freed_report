class System::Role < ActiveRecord::Base
  
  set_table_name "sm_roles"
  
  has_and_belongs_to_many :permissions, :join_table=>'sm_roles_permissions',:conditions => {:default_permission => false,:is_valid => true},:order =>"order_seq"
  
  has_many :users
  
  validates_presence_of :name, :message => "角色名不能为空!"
  
  validates_uniqueness_of :name, :message => "角色名不能重复!"
  
  validates_presence_of :permissions, :message => "权限不能为空!"
  
  def is_used_by(uid)
    users.each {|user| return true if user.id == uid}
    false
  end
  
  def is_default
    ['admin', 'configure', 'viewer'].include? name
  end
  
  def before_destroy
    if  User.count(:conditions => {:role_id => id }) > 0
      return false
    end
  end
  
  def after_update
    SecuritySync::Role.new(self).update
  end
  
  def after_destroy
    SecuritySync::Role.new(self).destroy
  end
  
  def after_create
    SecuritySync::Role.new(self).create
  end
  
  def is_admin
    name == "admin"
  end
  
end

