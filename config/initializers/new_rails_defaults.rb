# Be sure to restart your server when you modify this file.

# These settings change the behavior of Rails 2 apps and will be defaults
# for Rails 3. You can remove this initializer when Rails 3 is released.

if defined?(ActiveRecord)
  # Include Active Record class name as root for JSON serialized output.
  ActiveRecord::Base.include_root_in_json = false

  # Store the full class name (including module namespace) in STI type column.
  ActiveRecord::Base.store_full_sti_class = true
end

# Use ISO 8601 format for JSON serialized times and dates.
ActiveSupport.use_standard_json_time_format = true

# Don't escape HTML entities in JSON, leave that for the #json_escape helper.
# if you're including raw json in an HTML page.
ActiveSupport.escape_html_entities_in_json = false

my_formats = {
  :d => '%Y-%m-%d',
  :t  => '%H:%M:%S',
  :dt => '%Y-%m-%d %H:%M:%S',
  :td => '%H:%M:%S %Y-%m-%d',
  :md => '%m-%d'
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!({:default=>my_formats[:dt]})
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!({:default=>my_formats[:d]})
