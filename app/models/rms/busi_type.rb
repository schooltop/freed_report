class Rms::BusiType 
  attr_accessor :id, :name, :value ,:type_name
  def initialize hash
    @id        = hash[:id]
    @name      = hash[:name]
    @value     = hash[:value]
    @type_name = hash[:type_name]
  end

  def find_templates
    Rms::ReportTemplate.all :conditions => [value], :order => "report_name"
  end
end

