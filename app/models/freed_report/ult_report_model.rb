class FreedReport::UltReportModel < External
  set_table_name "ULT_REPORT_MODELS"
  set_sequence_name "ULT_REPORT_MODELS_ID"
  belongs_to :ultra_company_db_model, :class_name => "FreedReport::UltraCompanyDbModel", :foreign_key => "ultra_company_db_model_id"
  has_one :ultra_company_tabmenu, :class_name => "FreedReport::Tabmenu", :foreign_key => "ult_report_model_id"
  has_many :ultra_company_charts
  self.partial_updates = false

  def check_model_name
      @times={"hour"=>"小时","day"=>"天","week"=>"周","month"=>"月","all"=>"全部"}
      @areas={"ap"=>"AP","ac"=>"AC","sw"=>"交换机","town"=>"郊县","city"=>"地市","province"=>"省份","port"=>"热点"}
      self.name.to_s+(self.area_gran ? '(' : '')+@areas[self.area_gran].to_s+(self.area_gran ? ',' : '')+@times[self.time_gran].to_s+(self.area_gran ? ')' : '')
  end

  def report_show_title
    #报表显示列数组选项配置
    return_title=[]
    if self.show_title
    for title in self.show_title.split("|")
      return_title<<[title.to_s,title.to_s]
    end
    end
    return return_title
  end

  def report_link_title
    #父报表被钻取列数组选项配置
    return_title=[]
    if self.report_link
    for title in self.report_link.split("￥")
      return_title<<title.split('|')[0]
    end
    end
    return return_title
  end

  def report_hidden_title
    #隐藏列配置
     return_title=[]
    if self.crom
    for title in self.crom.split(",")
      return_title<<[title.to_s,title.to_s]
    end
    end
    return return_title
  end

  def report_link_parents
    #报表钻取源，一个被钻取报表可以有多个钻取来源。
    return_title=[]
    if self.report_chart
    for title in self.report_chart.split(",")
      return_title<<title
    end
    end
    return return_title
  end

  def parems_title
    #报表显示列数组选项配置
    return_title=[]
    if self.form_title
    for title in self.form_title.split("￥")
      return_title<<title.split('#')[1]
    end
    end
    return return_title
  end

end
