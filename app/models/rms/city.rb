class Rms::City < External
  set_table_name "citys"
  
  def self.all_cities
    all :conditions => ["cityid > ?", 0]
  end

end
