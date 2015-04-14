
  class FreedReport::UltraCompanyTabmenusUser < External
    set_table_name "ultra_company_tabmenus_users"
    set_sequence_name "tabmenus_users_id"
    belongs_to :ultra_company_tabmenu, :class_name => "FreedReport::Tabmenu", :foreign_key => "ultra_company_tabmenu_id"
  end
