class Membership < LimsActiveRecord
  belongs_to :user
  belongs_to :group
end
