class User < LimsActiveRecord
  has_many :data_files
  has_many :projects
  has_many :memberships
  has_many :groups, :through => :memberships
  # has_and_belongs_to_many :groups
end
