class Session < ActiveRecord::Base

  attr_accessor :decode_data

  after_destroy :destroyed_log

  def self.clean
    self.delete_all(["updated_at < ?", 1.hours.ago])
  end

  def is_valid
    user != nil
  end

  def user
    get_data.nil? ? nil : (get_data[:uid].nil? ? nil : User.find(get_data[:uid]))
  end

  def name
    get_data.nil? ? nil : get_data[:name]
  end

  def login
    get_data.nil? ? nil : get_data[:login]
  end

  def ip
    get_data.nil? ? nil : get_data[:ip]
  end

  def login_time
    get_data.nil? ? nil : get_data[:login_time]
  end

  def logout_time
    get_data.nil? ? nil : get_data[:logout_time]
  end

  def get_data
    unless @decode_data
      @decode_data = Marshal.load(Base64.decode64(data))
    end
    @decode_data
  end

  def to_json(options = {})
    json_value = super(options)
    session_value = ActiveSupport::JSON.decode(json_value)
    if user
      session_value['user'] = user.name
      session_value['login'] = user.login
    end
    session_value['user'] = name
    session_value['login'] = login
    session_value['ip'] = ip
    session_value['login_time'] = login_time
    session_value['logout_time'] = logout_time
    ActiveSupport::JSON.encode(session_value,options)
  end

  protected

  def destroyed_log
    if( user )
      printf("[KICKOUT] Session Id= %s, User = %s, Last Active At = (%s), From = (%s)\r\n ",
        session_id, user, updated_at.to_s, ip)
    end
  end

end
