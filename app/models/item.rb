class Item < LimsActiveRecord

  belongs_to :user
  belongs_to :folder

  has_many :project_attachments, :dependent => :destroy
  has_many :projects, :through => :project_attachments

  ###################################################################
  # paperclip attachment
  # note that we use 'original' as the style name so we don't have to
  # shuffle around temp files and worry about duplicates

  has_attached_file :attachment,
    :styles => { :original => {:md5_cmd => MD5_CMD } },
    :processors => [:checksum]

 
end
