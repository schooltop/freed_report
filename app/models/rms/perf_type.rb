class Rms::PerfType < External
  set_table_name "WLAN_INDEX_DEF"

  def to_json(options = {})
    super(options)
  end

  def self.index_units
    all_index = Rms::PerfType.find(:all,:order=>'id')
    all_index.to_hash{|type| [type.name_cn.upcase, type.name_unit] }
  end
end
