class Project < LimsActiveRecord


  belongs_to :user
  has_many :assets
  has_many :samples
  has_many :data_files
  has_many :project_pages 


  ## find all projects for a given username

  def self.getProjects(username)
    u = User.find(:first, :conditions => "login = '#{username}'")

    return u.projects

  end

end
