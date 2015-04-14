class Object
  def self.define_constant(name, value)
    cattr_reader name
    class_variable_set "@@#{name.to_s}".to_sym, value
  end
end
