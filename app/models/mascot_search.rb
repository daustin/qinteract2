class MascotSearch < ActiveRecord::Base

belongs_to :job
belongs_to :mascot_param

validates_presence_of :raw_dir

end
