class Dic::Code < ActiveRecord::Base
  set_table_name 'dic_codes'

  belongs_to :dic_type, :class_name => "Dic::Type", :foreign_key => "type_id"

  validates_presence_of :type_id,    :message => "字典类型不能为空"
  validates_presence_of :code_label, :message => "字典值不能为空"
  validates_presence_of :code_name, :message=> "字典编码不能为空"
  validates_uniqueness_of :code_label, :message => "同一字典类型的字典名称不能相同", :scope => [:type_id]
  validates_uniqueness_of :code_name, :message => "同一字典类型的字典编码不能相同", :scope => [:type_id]
  validates_presence_of :parent_id, :if => :type?

  named_scope :short, :select => "id, code_label"

  named_scope :dic_type_is, lambda { |type_name| { :joins => :dic_type, :conditions => { :dic_types => { :type_name => type_name } } } }

  def type?
    type_id == 42
  end

  class << self
    def count_ap_num_by_version user, page, sort = {},export =false,options ={}
      options.update({
          :select => "t2.code_label manu_name,t3.code_label type_name,
          t1.ap_software_rer software_ver,
          count(case t1.ap_fit when 1 then t1.id else null end) fit_apnum,
          count(case t1.ap_fit when 2 then t1.id else null end) fat_apnum",
          :from => "mit_aps t1,dic_codes t2, dic_codes t3",
          :conditions => "t1.ap_dn like '%#{user.domain.base}%'
          and t1.device_manu = t2.id
          and t1.ap_type = t3.id",
          :group => "manu_name,type_name,software_ver",
          :order => sort[:name].nil? ? "manu_name" : " #{sort[:name]} #{sort[:direction]}",
          :page => page[:page], :per_page => page[:page_size]
        })
      get_record(export,options)
    end
    
    def count_ac_num_by_version user, page, sort = {},export=false,options ={}
      options.update({
          :select => "t2.code_label manu_name,t3.code_label type_name,
          t1.software_ver,count(t1.id) ac_num",
          :from => "mit_acs t1,dic_codes t2,dic_codes t3",
          :conditions => "t1.ac_dn like '%#{user.domain.base}%'
          and t1.device_manu = t2.id
          and t1.ac_type = t3.id",
          :group => "manu_name,type_name,software_ver",
          :order => sort[:name].nil? ? "manu_name" : "#{sort[:name]} #{sort[:direction]}",
          :page => page[:page], :per_page => page[:page_size]
        })
      get_record(export,options)
    end

    def get_record(export,options)
      if export == true
        find_by_sql "select #{options[:select]} from #{options[:from]}
          where #{options[:conditions]} group by #{options[:group]}
          order by #{options[:order]}"
      else
        paginate_by_sql "select #{options[:select]} from #{options[:from]}
          where #{options[:conditions]} group by #{options[:group]}
          order by #{options[:order]}",
          :page => options[:page],:per_page => options[:per_page]
      end
    end
    
    def export_column_names
      ['type_label','code_name','code_label','is_valid','remark']
    end
    
    def all_ac_types user
      ac_type = Dic::Type.find(:first, :conditions => ["type_name = 'ac_type'"]).id
      find_by_sql("select * from dic_codes where type_id = #{ac_type} and is_valid = 1 and id in (select distinct ac_type from mit_acs where ac_dn like '%#{user.domain.base}')").collect {|c| [c.code_label,c.id]}.sort
    end

    def all_ap_types user
      ap_type = Dic::Type.find(:first, :conditions => ["type_name = 'ap_type'"]).id
      # find_by_sql("select * from dic_codes where type_id = #{ap_type} and is_valid = 1 and id in (select distinct ap_type from mit_aps where ap_dn like '%#{user.domain.base}')").collect {|c| [c.code_label,c.id]}.sort
      find_by_sql("select * from dic_codes t1 where exists (select 1 from mit_aps t2 where t1.id = t2.ap_type and t2.ap_dn like '%#{user.domain.base}') and t1.is_valid = 1 and type_id = #{ap_type}").collect {|c| [c.code_label,c.id]}.sort
    end

    def all_sw_types user
      sw_type = Dic::Type.find(:first, :conditions => ["type_name = 'sw_type'"]).id
      find_by_sql("select * from dic_codes where type_id = #{sw_type} and is_valid = 1 and id in (select distinct sw_type from mit_switchs where sw_dn like '%#{user.domain.base}')").collect {|c| [c.code_label,c.id]}.sort
    end

    def ap_vender user
      find_by_sql("select * from dic_codes t1 where t1.is_valid = 1 and t1.type_id in (select t2.id from dic_types t2 where t2.type_name = 'device_manu') 
                   and exists (select 1 from mit_aps t3 where t3.device_manu = t1.id and t3.ap_dn like '%#{user.domain.base}')") 
    end

    def ap_type user
      find_by_sql("select * from dic_codes t1 where t1.is_valid = 1 and t1.type_id in (select id from dic_types t2 where t2.type_name = 'ap_type')
                   and exists (select 1 from mit_aps t3 where t3.ap_type = t1.id and t3.ap_dn like '%#{user.domain.base}')") 
    end

    def ac_vender user
      self.all_ac_vender(user).map{|c| [c.code_label, c.id]}.sort
    end

    def ac_type user
      self.all_ac_type(user).map{|c| [c.code_label, c.id]}.sort
    end

    def ac_ver user 
      Ac.ver user
    end

    def all_ac_vender user
      find_by_sql("select * from dic_codes t1 where t1.is_valid = 1 and t1.type_id in (select t2.id from dic_types t2 where t2.type_name = 'device_manu') 
                   and exists (select 1 from mit_acs t3 where t3.device_manu = t1.id and t3.ac_dn like '%#{user.domain.base}')") 
    end

    def all_ac_type user
      find_by_sql("select * from dic_codes t1 where t1.is_valid = 1 and t1.type_id in (select id from dic_types t2 where t2.type_name = 'ac_type')
                   and exists (select 1 from mit_acs t3 where t3.ac_type = t1.id and t3.ac_dn like '%#{user.domain.base}')")
    end

    def to_hash codes
      hash = {}
      if codes.is_a? Array 
        codes.each do |c| 
          hash[c.id] = c.code_label
        end
      elsif codes.is_a? Dic::Code
        hash[codes.id] = codes.code_label
      end
      hash
    end
  end
end
