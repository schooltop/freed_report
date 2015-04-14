class Time
  
  def at_beginning_of_hour
    at_beginning_of_interval(:hour)
  end
  
  def at_end_of_hour
    at_end_of_interval(:hour)
  end
  
  def at_end_of_interval(interval_type)
    if [:year, :month, :week, :day].include? interval_type
      self.to_date.send("at_end_of_#{interval_type}")
    else
      self - (self.to_i % 1.send(interval_type)) + 1.send(interval_type) - 1
    end
  end
  
  def at_beginning_of_interval(interval_type)
    if [:year, :month, :week, :day].include? interval_type
      self.to_date.send("at_beginning_of_#{interval_type}")
    else
      self - (self.to_i % 1.send(interval_type))
    end
  end
end