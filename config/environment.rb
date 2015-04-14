# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

ENV['NLS_LANG'] ||= 'AMERICAN_AMERICA.UTF8'
#ENV['ORACLE_HOME'] = "/oracle/10g"
#ENV['LD_LIBRARY_PATH'] = "/opt/oracle/instantclient10_1"


# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Dir[RAILS_ROOT + "/ext/**/*.rb"].each{|file|
  require file
}

Rails::Initializer.run do |config|
  log_level = :error
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # Add additional load paths for your own custom dirs
config.load_paths += %W( #{RAILS_ROOT}/app/jobs )
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  #config.time_zone = 'UTC'
  config.action_controller.session = {
    :session_key => '_opengoss_session',
    :secret      => '31d4c738f0d7267f7edf9ea5df15cc6558132cc7a2fdc34376e43dfa6e34eec62e540751ba94dc673267a2d404e3b215a32b1cba324cae058feb6266f4317634'
  } 
  config.action_controller.session_store = :active_record_store

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :cn
  config.plugins = [:all ]

  config.action_mailer.raise_delivery_errors = true #错误异常是事抛给应用程序
end

$BIZ_SERVER='localhost'

$BIZ_PORT=8088

$EVENT_SERVER='localhost'

$EVENT_PORT=8088

#$RRDB = "http://172.17.5.165:8000/"
#$RRA_DIR = "/opt/mobile/rrdb/data"

$ERRDB_SERVER = "192.168.101.80"
#$REDIS_HOSRDB_SERVER = "172.17.5.158" 
$ERRDB_PORT = "8080"

$CFG = YAML.load(ERB.new(IO.read("#{RAILS_ROOT}/config/database.yml")).result)['wifi_rms']
$SUPPORT_REPEATER=true
$EXPORT_LIMIT=10000
$PROVINCE_ID = 30
$LOCATION_ID = "jx"
$FM_DIR = "FM"
$PM_DIR = "PM"
$CM_DIR = "CM"
$AUTH_URL = "http://192.168.101.80:58045/pasm/pasmservices/PASMWebService"

require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "http://192.168.101.80:58045/ucas"
)
$cas_logger = CASClient::Logger.new(RAILS_ROOT+'/log/cas.log')
$cas_logger.level = Logger::DEBUG
$HOURLY_REPORT=true
require "personalized"
