class LimsActiveRecord < ActiveRecord::Base
  self.abstract_class = true
  self.establish_connection "LIMS"

end
