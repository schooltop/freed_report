
  class FreedReport::Tabmenu < External
  set_table_name "ultra_company_tabmenus"
  set_sequence_name "ultra_company_tabmenus_id"
  belongs_to :ult_report_model, :class_name => "FreedReport::UltReportModel", :foreign_key => "ult_report_model_id"
  has_many :ultra_company_tabmenus_users, :class_name => "FreedReport::UltraCompanyTabmenusUser", :foreign_key => "ultra_company_tabmenu_id"
   def childmenus
    childmenus=FreedReport::Tabmenu.find_by_sql("select min(id) id, name,min(url)url FROM ultra_company_tabmenus where parent_id=#{self.id}and parent_id!=id and top_style<>1  group by name")
    return childmenus
   end
   def self.menuitems
     current_menuitems=FreedReport::Tabmenu.find(:all,:conditions=>"parent_id is null and top_style<>1 ",:order=>"id desc")
     return current_menuitems
   end
   def self.parent_menus
     parent_menu=FreedReport::Tabmenu.find(:all,:conditions=>"parent_id = id ",:order=>"id")
   end
   def self.parent_name(parent_id)
     parent_menu=FreedReport::Tabmenu.find_by_id(parent_id.to_i)
     parent_menu ? parentname=parent_menu.name : parentname="导航栏"
     return parentname
   end
  end
