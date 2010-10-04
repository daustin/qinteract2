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

  def file_hash
    #build hash to return
    files = {}
    files[:lims_files] = []
    files[:analysis_files] = []

    settings = self.jobs.last.analysis_setting
    runscript = self.jobs.last.runscript

    # first get the fasta db
    unless settings.nil?
      fasta_size = File.size("#{DB_ROOT}/#{settings.prot_db}")
      files[:fasta] = {:path => "#{DB_ROOT}/#{settings.prot_db}", :size => fasta_size}
    end

    # now lets get the LIMS files

    unless runscript.nil?
      runscript.each_line do |l|
        if l =~ /#{DATAFILE_PATH_PREFIX}/
          path = l.split(" ")[1].gsub(/\/mnt\/san\/lims1/, '/lims')
          if File.exist? path
            size = File.size(path)
	  else
            #try to find it!
            find = `find /lims/data_files/*/#{File.basename(path)}`
            best = ''
            find.each {|k| best = k }
            if File.exist? best
               size = File.size(best)
            else
              next
            end

          end
          files[:lims_files] << {:path => path, :size => size}            
        end
      end      
    end

    # finally analysis files
    if self.archived == 1
      # go to tgz directory
      Dir.chdir("/wdbackup") do 
        tar_out = `tar -tvf archive_#{self.id}.tgz`
        tar_out.each do |l|
          la = l.split(" ")
          path = la[5]
          size = la[2].to_i
          files[:analysis_files] << { :path => path, :size => size } unless size == 0
        end

      end
      
    else
      Dir.chdir("#{QINTERACT_PROJECT_ROOT}/#{self.path}") do
        Dir.glob("*") do |f|
          size = File.size(f)
          path = "#{QINTERACT_PROJECT_ROOT}/#{self.path}/#{f}"
          files[:analysis_files] << {:path => path, :size => size}
        end
      end
    end

    return files
    
  end
  
  
  
end

