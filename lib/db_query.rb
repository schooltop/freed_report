require 'rubygems'
require 'dbi'

module DbQuery
  def bind_params(sth_db, options)
    return if(sth_db.nil? || options.nil?)
    options.each_key { |key| sth_db.bind_param(":#{key.to_s}", options[key]) }
  end
  
  def with_db_ora
    userName = $CFG['username']
    password = $CFG['password']
    database = $CFG['database']
    database = "DBI:OCI8:#{database}"

    dbh = DBI.connect(database,userName,password)
    begin
      yield dbh
    ensure
      dbh.disconnect
    end
  end
end
