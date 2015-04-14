class Permission < ActiveRecord::Base

  set_table_name "sm_permissions"

  has_and_belongs_to_many :roles,:join_table => 'sm_roles_permissions', :class_name => "System::Role"

  def self.default
    find(:all, :conditions => ["default_permission = 1"])
  end
end
