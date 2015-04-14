# To change this template, choose Tools | Templates
# and open the template in the editor.

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module Quoting
      alias :quote_old :quote
      @@nested_indicator = "@"
      def quote(value, column = nil)
        if(value.respond_to?(:start_with?) && value.start_with?(@@nested_indicator))
          "(#{value.delete(@@nested_indicator)})"
        else
          quote_old(value, column)
        end
      end
    end
  end
end