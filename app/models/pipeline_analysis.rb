class PipelineAnalysis < ActiveRecord::Base
  before_save :setPath

  belongs_to :pipeline_project
  
  has_many :jobs,
           :dependent => :destroy
  
  validates_presence_of :name, :owner
  
  def before_destroy 
    system("rm -rf #{PROJECT_ROOT}/#{self.path}")
    system("rm -f #{ARCHIVE_ROOT}/archive_#{self.id}.tgz") 
  end
  
  
  def setPath
    
    self.path =  "#{pipeline_project.path}/#{owner}_#{id}"
    
  end
  

  def getFiles
    @files = [] 
    puts attribute_names()
    Dir.chdir("#{QINTERACT_PROJECT_ROOT}/#{self.path}") do
      @ps = IO.popen("ls -1 *.*")
      @ps.readlines.each do |file|
        
        @temp = file.chomp
        @files << "#{@temp} "
        
        
      end
      @ps.close
    end
    
    return @files  
  end



end
