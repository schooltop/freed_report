class Time
  def to_cn
    self.strftime("%Y年%m月%d日")
  end
  def to_ss
    self.strftime("%Y-%m-%d %H:%M:%S")
  end
end

class  ActiveRecord::Base   
  def self.find_in_site(id)
    with_scope(:find => {:conditions => "id = #{id} and site_id = #{AppConfig.site_id}"}) do
      find :first
    end
  end   

  def self.find_in_subject(id)
    with_scope(:find => {:conditions => "id = #{id} and subject_id = #{AppConfig.subject_id}"}) do
      find :first
    end
  end
end

class Float
    def floor_to(x)
    (self * 10**x).floor.to_f / 10**x
  end
end

class String
  def ip2long
    ip = self
    long = 0
    ip.split(/\./).each_with_index do |b, i|
      long += b.to_i * (255 ** (4-i))
    end
    long
  end

  def last_n(n=6)
    self[-n, n]
  end
end

class Numeric
  def long2ip 
    long = self
    ip = []
    4.downto(1) do |i|
      ip.push(long.to_i / (255 ** i))
      long = long.to_i % (255 ** i)
    end
    ip.join(".")
  end 
end

class Array
  def to_aa
    self.map{|x| [x, self.index(x) + 1]}
  end
end

class String
  def filter_csv_key
    self.clean.gsub(",", "，").gsub(";", "；")
  end

  def filter_csv_key!
    result = self.filter_csv_key
    self.sub!(/.*/, result)
  end

  def clean
    self.gsub(/((\r|\n)*)/, '')
  end

  def filter_point_tag
    r = Regexp.new('(\[\{[^\}]+?\}\])')
    self.gsub!(r, '')
  end

  def self.uuid
    `uuidgen`.strip
  end

  def utf8_to_gb2321
    encode_convert(self, "gb2321", "UTF-8")
  end

  def gb2321_to_utf8
    encode_convert(self, "UTF-8", "gb2321")
  end

  def utf8_to_gb2312
    encode_convert(self, "GB2312", "UTF-8") 
  end

  def gb2312_to_utf8
    encode_convert(self, "UTF-8", "GB2312") 
  end

  def utf8_to_utf16
    encode_convert(self, "UTF-16LE", "UTF-8")
  end

  def utf8?
    begin
      utf8_arr = self.unpack('U*')
      true if utf8_arr && utf8_arr.size > 0
    rescue
      false
    end
  end
  
  def self.random_alphanumeric(size=16)
    (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
  end
  
  def self.random_filename
    "#{Digest::SHA1.hexdigest("-#{String.random_alphanumeric(16)}-#{Time.now.to_s}")}"
  end

  private
  def encode_convert(s, to, from)
    require 'iconv'
    begin
      converter = Iconv.new(to, from)
      converter.iconv(s)
    rescue
      s
    end
  end
end

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"field field-error required\">#{html_tag}</span>" }

ActionController::Routing::RouteSet::Mapper.class_eval do   
  protected  

  def map_unnamed_routes(map, path_without_format, options)  
    map.connect(path_without_format, options)  
    #map.connect("#{path_without_format}.:format", options)  
  end  

  def map_named_routes(map, name, path_without_format, options)  
    map.named_route(name, path_without_format, options)  
    #map.named_route("formatted_#{name}", "#{path_without_format}.:format", options)  
  end  
end


class KuxueTools
  class << self 
    def p(s)
      if ENV['RAILS_ENV'] == 'development' 
        puts "\n========Begin of KuxueTools.p==========\n#{s.inspect}\n========End of KuxueTools.p==========\n" 
      end
    end
  end
end

class OS
  require "rbconfig"
  class << self
    def get
      Config::CONFIG["host_os"].downcase
    end

    def is_linux?
      !(get =~ /linux/).nil?
    end
  end
end
