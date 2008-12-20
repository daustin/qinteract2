class RawDir

  attr_writer :rel_path
  attr_reader :rel_path

  attr_writer :dir_name
  attr_reader :dir_name

  
  def initialize
    @rel_path = ''

    @dir_name = ''
  end

  def createInstance(p)
    p = p.chomp
    p = p.chomp("/")
    @rel_path = p
    @temp = p.split('/')
    @dir_name = @temp.pop if @temp.size > 0
  end


  def self.getRawDirs(parent)
    @command = "#{SEQUEST_SSH_PREFIX} ls -d1 #{SEQUEST_RESULTS}"

    if parent == ''
       @command += "/*/"
    else
       parent = parent.chomp
       parent = parent.chomp("/")
       @command += "/#{parent}/*/"
    end

    @folders = []
    
    @ps = IO.popen(@command)
    @fn = @ps.readlines
    @fn.each do |path| 
      @temp = RawDir.new
      path = path.chomp
      path = path.chomp("/")
      @a = path.split('/')
      @temp.dir_name = @a.pop
      @temp.rel_path = path.slice(SEQUEST_RESULTS.length+1, path.length)
      @folders << @temp
      
    end
    @ps.close
    return @folders
  end

end
