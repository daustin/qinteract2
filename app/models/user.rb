class User < LimsActiveRecord

  has_many :memberships, :dependent => :destroy
  has_many :projects, :through => :memberships
  has_many :items
  
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation, :admin

  attr_accessor :password
  
  
end
