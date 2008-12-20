class SequestSearch < ActiveRecord::Base

belongs_to :job
belongs_to :sequest_param

validates_presence_of :raw_dir, :sequest_param_id
end
