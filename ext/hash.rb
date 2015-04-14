class Hash
  def filter_keys_by_value
    self.keys.select{|key|
      yield(self[key])
    }
  end

  # Returns a new hash with only the given keys.
  def only(*keys)
    kept = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    reject { |key,| !kept.include? key }
  end

  # Replaces the hash with only the given keys.
  def only!(*keys)
    replace(only(*keys))
  end
  
  # Returns a new hash without the given keys
  def except(*keys)
    kept = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    reject { |key,| kept.include? key }
  end
  
  # Replaces the hash without the given keys
  def except!(*keys)
    replace(except(*keys))
  end

  def join(sep)
    self.collect{|key, value| "#{key}=#{value}"}.join(sep)
  end
  
  def method_missing(m, *args, &block)
    self[m]
  end
  
end