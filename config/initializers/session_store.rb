# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_freed_report_session',
  :secret      => '3c0a3603730943b214688c3244379c0e182a0f819b8efdc469d8eba1c5b5b8bed4f5c5e54c27758f5a7386df51276e5452d5ee361b8293f668710953a89201ee'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
