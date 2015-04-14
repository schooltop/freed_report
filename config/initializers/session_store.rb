# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_webport_new_session',
  :secret      => 'c5e1fe3c0e68dac70848c846ed7c1d08dbeedb8d7cfd9485e0dd489e3e5c3f0de29cd7c3519019ede38292537b39156138a1d6edaaf4f99bc59dc85441e2bf9e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
