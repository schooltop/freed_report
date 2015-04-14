class FreedReport::UltReportModel < External
  set_table_name "ULT_REPORT_MODELS"
  set_sequence_name "ULT_REPORT_MODELS_ID"
  belongs_to :ultra_company_db_model, :class_name => "FreedReport::UltraCompanyDbModel", :foreign_key => "ultra_company_db_model_id"
  has_one :ultra_company_tabmenu, :class_name => "FreedReport::Tabmenu", :foreign_key => "ult_report_model_id"
  self.partial_updates = false
end
