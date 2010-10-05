class Item < LimsActiveRecord

  belongs_to :user
  belongs_to :folder

  has_many :project_attachments, :dependent => :destroy
  has_many :projects, :through => :project_attachments

  # builds paperclip path 

  def path
    
    return "#{DATAFILE_PATH_PREFIX}/system/attachment/#{self.id}/original/#{self.attachment_file_name}"
        
  end
  
  
  
  
end
