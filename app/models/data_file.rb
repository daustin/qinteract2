class DataFile < Asset
  has_and_belongs_to_many :samples  

  ## find all files that belong to the given sample and are RAW files

   def self.getRawFiles(smplid)
     Sample.find(smplid).data_files(:conditions => ["lower(filesystem_name) like ? OR lower(filesystem_name) like ?", "%.raw", "%.mzxml"])

  end


end
