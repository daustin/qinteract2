class PipelineProject < ActiveRecord::Base
  has_many :pipeline_analyses
  validates_presence_of :name, :owner
  
  def self.desc
    find(:all,
         :order => "owner asc, created_at desc")
  end
  
  def self.getUsernames
    find_by_sql("select distinct owner from pipeline_projects order by owner")
  end
  
  def self.filterUsername(username)
    find(:all,
         :conditions => ["owner = ?", username], 
         :order => "owner asc, created_at desc")
  end

  def setPath
    if created_at.nil?
      self.created_at = Time.now
    end
    self.path = "#{owner}_#{created_at.strftime("%Y%m%d%H%M%S")}"
    
  end

  
  
end





