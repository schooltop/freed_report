class String
  # def utf8?
  #   unpack('U*') rescue return false
  #   true
  # end
  
  # def to_iso
  #   to, from = 'GB2312//IGNORE', 'UTF-8//IGNORE'
  #   Iconv.conv(to, from, self)
  # end

  # def to_utf8
  #    to, from = 'UTF-8//IGNORE', 'GB2312//IGNORE'
  #   Iconv.conv(to, from, self)
  # end
  
  def to_iso
    if OS.is_linux?
      to, from = 'GB2312//IGNORE', 'UTF-8//IGNORE'
    else 
      to, from = 'GB2312', 'UTF-8'
    end
    Iconv.conv(to, from, self)
  end
  
  def to_utf8
    if OS.is_linux?
      to, from = 'UTF-8//IGNORE', 'GB2312//IGNORE'
    else 
      to, from = 'UTF-8', 'GB2312'
    end
    Iconv.conv(to, from, self)
  end

  def gbk2utf8
    to, from = 'UTF-8//IGNORE', 'GB2312//IGNORE'
    Iconv.conv(to, from, self)
  end

  def is_integer?
    self =~ /\A[+-]?\d+\Z/
  end
end
