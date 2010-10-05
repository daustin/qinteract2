class Project < LimsActiveRecord

  has_many :project_attachments, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  
  has_many :users, :through => :memberships
  has_many :items, :through => :project_attachments
  
end
