class FreedReport::UltraCompanyDbModel < External
  set_table_name "ULTRA_COMPANY_DB_MODELS"
  set_sequence_name "ULTRA_COMPANY_DB_MODELS_ID"
  has_many :ult_report_model, :class_name => "FreedReport::UltReportModel", :foreign_key => "ultra_company_db_model_id"
end
