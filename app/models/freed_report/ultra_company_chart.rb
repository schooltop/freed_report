class FreedReport::UltraCompanyChart < External
  set_table_name "ULTRA_COMPANY_CHARTS"
  set_sequence_name "ULTRA_COMPANY_CHARTS_ID"
  belongs_to :ultra_company_db_model, :class_name => "FreedReport::UltraCompanyDbModel", :foreign_key => "ultra_company_db_model_id"
  belongs_to :ult_report_model, :class_name => "FreedReport::UltReportModel", :foreign_key => "ult_report_model_id"
  belongs_to :ultra_company_chart_style, :class_name => "FreedReport::UltraCompanyChartStyle", :foreign_key => "ultra_company_chart_style_id"
  self.partial_updates = false

  def parent_chart
    @parent_chart=FreedReport::UltraCompanyChart.find(self.parent_id)
    @parent_chart.action_title
  end

  def has_parent_chart?
    if self.parent_id
      return true
    else
      return false
    end
  end
end
