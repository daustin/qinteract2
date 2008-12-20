class PipelineAnalysis < ActiveRecord::Base
 belongs_to :pipeline_project
 has_many :jobs
 validates_presence_of :name, :owner
  
  
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
