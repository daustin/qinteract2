# require 'uuid'
class Asset < LimsActiveRecord
  belongs_to :user
  belongs_to :project
  has_many :asset_annotations
  before_create :set_uuid
  private 
  # def set_uuid
  #  self.uuid = UUID.new()
  # end
end
