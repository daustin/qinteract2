class Mscluster  < ActiveRecord::Base

belongs_to :job
validates_presence_of :raw_dir


end
