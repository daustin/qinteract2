class ProjectAttachment < LimsActiveRecord
  
  belongs_to :item
  belongs_to :project
  
  
end
