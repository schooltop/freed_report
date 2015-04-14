class Rms::WlanIndexDef < External
  set_table_name "wlan_index_def"
  def format data
    s = ""
    if is_percent.eql?(1)
      data = data*100
      s = "%"
    end
    sprintf("%.#{decimal_digits}f",data) << s
  end

  def format_head header
    s = ""
    if !name_unit.nil? && name_unit.length > 0
      header = header
      s = "("+name_unit+")"
    end
    sprintf(header) << s
  end
  
  class << self
    def index name_cn
      find_by_name_cn(name_cn)
    end
  end
end
