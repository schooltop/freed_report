class External < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :wifi_rms
end