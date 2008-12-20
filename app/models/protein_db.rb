class ProteinDb
  
  attr_reader :filename
  attr_reader :rel_path
  attr_writer :filename
  attr_writer :rel_path


  def initialize
    @filename = ''
    @rel_path = ''

  end



  # returns an array of ProteinDb
  def self.getDbFiles
    @files = []
    @ps = IO.popen("ls -1 #{DB_ROOT}")
    @ps.readlines.each do |dir|
      @ps1 = IO.popen("ls -1 #{DB_ROOT}/#{dir}") 
      @ps1.readlines.each do |file|
        @temp = ProteinDb.new
        @temp.filename = file.chomp
        @temp.rel_path = "#{dir.chomp}/#{file.chomp}"
        @files << @temp
      end
      @ps1.close
    end
    @ps.close
    return @files


  end

  # returns an array of the filenames for ProteinDb
  def self.getHash
    @files = ProteinDb.getDbFiles
    @filearray = []
    @files.each do |file|
      @filearray << ["#{file.filename}", "#{file.rel_path}"]
    end
    return @filearray
  end

  def self.getFilenames
    @files = ProteinDb.getDbFiles
    @filearray = []
    @files.each do |file|
      @filearray << "#{file.filename}"
    end
    return @filearray
  end

  def self.getSequestDBFilenames
    files = []
    ps = IO.popen("#{SEQUEST_SSH_PREFIX} ls -1 #{SEQUEST_DATABASE}")
    fn = ps.readlines
    fn.each do |name| 
  
      
      files << ["#{name.chomp}", "S:\\sequest\\database\\#{name.chomp}"]
    end
    ps.close
   return files

  end

end
