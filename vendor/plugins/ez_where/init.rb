require 'caboose/ez'
require 'caboose/clause'
require 'caboose/condition'
require 'caboose/hash'
require 'caboose/nested_query_support'

ActiveRecord::Base.send :include, Caboose::EZ