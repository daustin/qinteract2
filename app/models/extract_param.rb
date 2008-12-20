class ExtractParam < ActiveRecord::Base

  has_many :extract_dtas
  validates_uniqueness_of :filename

  @@switches = [ 'F', 'L', 'B','T','M', 'G', 'I', 'A', 'R'] #old

  
  # @@switches = [ 'F', 'L', 'B','T','I'] #modified for decon msn

  def validate
    errors.add_on_empty %w( filename )
    errors.add("filename", "cannot have spaces.") if filename =~ /\s+/
  end

  def initialize (params=nil)
    # first call super so that all the attributes are available
    if params.nil? then
      params = { :B => 600, :T => 3500, :M => 1.4000, :S => 1, :G => 1, :I => 10, 
      :A => 'HTFEMAOSLC', :R => 5}
    end

    super(params)
    
  end
  
  def switches
    return @@switches
  end

  def exportToFile()
    #this method is responsible for dumping the file output from this params object.  
    #some of the output fields may need to be constructed on the fly, like enzymes. 
    #the method prepVarForFile is supposed to automatically check for these special fields and make adjustments

    file = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    file += "<!DOCTYPE extract_msn SYSTEM \"extract_msn.dtd\">\n\n"
    file += "<extract_msn>\n\n"
    
    @@switches.each do |v|
       
      file += "<option switch=\"-#{v}\">#{prepVarForFile(v)}</option>\n" unless prepVarForFile(v).nil?
      
      
    end
    
    file += "<data_file/>\n"
    
    file += "</extract_msn>\n\n"
    
    return file
    
  end


  def prepVarForFile(v)

	if self[v].nil?	
	   return nil
        elsif self[v].to_s.empty?
	    return nil
	else
	   return self[v] 
	end

  end



  # returns an array of ExtractParamsFiles
  def self.getParamsFiles
    @files = []
    @ps = IO.popen("#{SEQUEST_SSH_PREFIX} ls -1 #{SEQUEST_EXTRACT_PARAMS}")
    @fn = @ps.readlines
    @fn.each do |name| 
      @temp = ExtractParamsFile.new
      @temp.filename = name.chomp
      @files << @temp
    end
    @ps.close
    return @files


  end

  # returns an array of the filenames for ExtractParamsFiles
  def self.getFilenames
    @files = ExtractParamsFile.getParamsFiles
    @filenames = []
    @files.each do |file|
      @filenames << file.filename
    end
    return @filenames
  end

  def self.getContents(fn)
    @ps = IO.popen("#{SEQUEST_SSH_PREFIX} cat #{SEQUEST_EXTRACT_PARAMS}/#{fn}")
    @out = @ps.read
    @ps.close
    return @out

  end


end
