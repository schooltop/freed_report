module ActionView
  module Helpers #:nodoc:
    module UrlHelper
      private
      def method_javascript_function(method, url = '', href = nil)
        action = (href && url.size > 0) ? "'#{url}'" : 'this.href'
        submit_function =
          "var f = document.createElement('form'); f.style.display = 'none'; " +
          "this.parentNode.appendChild(f); f.method = 'POST'; f.action = #{action};"
        
        unless method == :post
          submit_function << "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); "
          submit_function << "m.setAttribute('name', '_method'); m.setAttribute('value', '#{method}'); f.appendChild(m);"
        end
        params.delete(:action)
        params.delete(:controller)
        params.each_pair { |key, value|
          submit_function << "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); "
          if(value.is_a?(Array))
            value.each {|v|
              submit_function << "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); "
              submit_function << "m.setAttribute('name', '#{key}[]'); m.setAttribute('value', '#{v}'); f.appendChild(m);"
            }
          elsif value.is_a?(Hash)
            value.each_pair { |key1, value1|
              if(value1.is_a?(Array))
                value1.each { |v|
                  submit_function << "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); "
                  submit_function << "m.setAttribute('name', '#{key}[#{key1}][]'); m.setAttribute('value', '#{v}'); f.appendChild(m);"
                }
              else
                submit_function << "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); "
                submit_function << "m.setAttribute('name', '#{key}[#{key1}]'); m.setAttribute('value', '#{value1}'); f.appendChild(m);"
              end
            }
          else
            submit_function << "m.setAttribute('name', '#{key}'); m.setAttribute('value', '#{value}'); f.appendChild(m);"
          end
        }
        if protect_against_forgery?
          submit_function << "var s = document.createElement('input'); s.setAttribute('type', 'hidden'); "
          submit_function << "s.setAttribute('name', '#{request_forgery_protection_token}'); s.setAttribute('value', '#{escape_javascript form_authenticity_token}'); f.appendChild(s);"
        end
        submit_function << "f.submit();"
      end
    end
  end
end