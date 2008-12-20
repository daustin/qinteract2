class ExtractDta < ActiveRecord::Base

  belongs_to :extract_param
  belongs_to :job
  
  validates_presence_of :raw_dir, :extract_param_id


end
