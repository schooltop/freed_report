# desc "Explaining what the task does"
# task :ui_for_rails do
#   # Task goes here
# end
require 'yaml'
require File.dirname(__FILE__) + '/../lib/ui_for_rails'

namespace :ui do
  #  desc "migrate a file like 'stylesheets/base/core.css' form the source_dir to build_dir"
  #  task :migrate,:filename do |t,args|
  #    UiForRails::UiForRails.migrate args[:filename]
  #  end
  #  desc "build a file like 'javascripts/base/core.js'"
  #  task :build,:filename do |t,args|
  #    UiForRails::UiForRails.build args[:filename]
  #  end
  desc "compress code for product"
  task :build do
    UiForRails::UiForRails.build
  end

  desc "Merge the code with the rules in \#{RAILSROOT}/config/ui.yml"
  task :merge do
    UiForRails::UiForRails.merge
  end

  desc "Copy the code to public folder"
  task :migrate do
    UiForRails::UiForRails.migrate
  end

  desc "Copy the code to public folder,Generate \#{RAILSROOT}config/ui.yml for the code merger"
  task :init do
    UiForRails::UiForRails.init
  end

  desc "Copy the code to public folder,Force to generate \#{RAILSROOT}config/ui.yml for the code merger"
  task :init! do
    UiForRails::UiForRails.init!
  end
end
