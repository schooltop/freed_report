class Array
  def method_missing(meth, *args)
    self.each { |item|
      item.instance_send(meth, *args) if(item.respond_to?(meth))
    }
  end

  def to_hash()
    hash = {}
    each { |a|
      item = yield a
      hash[item[0]] = item[1] unless item[0].nil?
    }
    hash
  end
end
