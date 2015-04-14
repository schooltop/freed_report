module Report::RadiusReportHelper
  def is_radius_column_visible(column_name, data)
    unless data.empty?
      return !data.first.attributes[column_name].blank?
    end
    return true
  end
end