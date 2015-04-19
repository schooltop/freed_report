class FreedReport::UltraCompanyChartStyle < External
  set_table_name "ULTRA_COMPANY_CHART_STYLES"
  #set_sequence_name "ULTRA_COMPANY_CHARTS_ID"
  has_many :ultra_company_charts, :class_name => "FreedReport::UltraCompanyChart", :foreign_key => "ultra_company_chart_style_id"

end
