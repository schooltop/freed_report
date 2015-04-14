class Domain < ActiveRecord::Base

  set_table_name "sm_domains"
  
  has_many :users

  #  has_and_belongs_to_many :resources, :join_table => 'sm_domains_resources'

  validates_presence_of :name, :message => "域名不能为空!"

  validates_uniqueness_of :name, :message => "域名不能重复!"

  validates_length_of :name, :within => 1..20

  validates_presence_of :base, :message => "管理域DN不能为空!"

  def has_users?
    users.size > 0
  end
  
  def after_update
    SecuritySync::Resource.new(self).update
  end
  
  def after_destroy
    SecuritySync::Resource.new(self).destroy
  end
  
  def after_create
    SecuritySync::Resource.new(self).create
  end

end
