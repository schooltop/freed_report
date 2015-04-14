# Include hook code here
#
#require 'helpers'
#ActionView::Base.send(:include, UiForRails::Helpers)
#
#init is in [rails/init.rb]
require 'ui'
require 'helpers'
ActionView::Base.send(:include, UI::Helpers)
ActiveRecord::Base.send(:include, UI::ActiveRecord)
ActionController::Base.send(:include, UI::ActionController, UI::Helpers)

