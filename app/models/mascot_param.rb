require 'net/http'

class MascotParam < ActiveRecord::Base

  has_many :mascot_searches
  validates_uniqueness_of :filename

  #these fields are outputed to the filesystem for use by sequest

  
  @@fields = ['COM',
              'SEG',
              'TOL',
              'TOLU',
              'ITOL',
              'ITOLU',
              'PFA',
              'DB',
              'MODS',
              'MASS',
              'CLE',
              'SEARCH',
              'USERNAME',
              'USEREMAIL',
              'CHARGE',
              'REPORT',
              'OVERVIEW',
              'FORMAT',
              'IT_MODS',
              'PRECURSOR',
              'TAXONOMY',
              'REPTYPE',
              'ICAT',
              'INSTRUMENT']


  
  def initialize (params=nil)
    
    if params.nil? then
      params = { 
        :SEARCH => "MIS", 
        :MODS => "Acetyl (K),Acetyl (N-term),Acetyl (Protein N-term)", 
        :IT_MODS => "Methylthio (C),NIPCAM (C),Oxidation (M)", 
        :CHARGE => "1+",
        :MASS => "Monoisotopic",
        :TOL => "0.5",
        :REPTYPE => "Peptide",
        :ITOL => "0.5"    
      }
      
    end
    
    super(params)
    
  end
  

  def validate
    errors.add_on_empty %w( filename )
    errors.add("filename", "cannot have spaces.") if filename =~ /\s+/
  end


  
  def fields
    return @@fields
  end

  #reads and parses given array of lines. loads associated class vars. 
  def importVars list
    #puts instance_variables
    list.each_line do |l|
      #remove trailing ;comments
      line = l.split(';').at(0).strip
      #first let's parse the line

      parseImportLine(line)

    end


  end

  def exportToFile()
    #this method is responsible for dumping the file output from this params object.  
    #some of the output fields may need to be constructed on the fly, like enzymes. 
    #the method prepVarForFile is supposed to automatically check for these special fields and make adjustments

    file = ""
    
    @@fields.each do |v|
        
      file += "#{v}=#{prepVarForFile(v)}\r\n"

    end

    return file

  end


  def prepVarForFile(v)
     
    tempstr = ''
    
    tempstr = self[v] unless self[v].nil?
    
    return tempstr

  end

  def parseImportLine(line)
    if ! (line[0,1].eql?("[") || line.empty?) then
      temparray = line.split('=')
      if(temparray.length>1) then
        
        self["#{temparray[0].strip}"]="#{temparray[1].strip}"     
        
      end
      
    end 
  end
  

  # returns an array of MascotParamsFiles deprecated
  def self.getParamsFiles
    files = []
    ps = IO.popen("#{SEQUEST_SSH_PREFIX} ls -1 #{MASCOT_PARAMS}")
    fn = ps.readlines
    fn.each do |name| 
  
      temp = MascotParamsFile.new({:filename => name.chomp})
      files << temp
    end
    ps.close
   return files

  end

  # returns an array of the filenames for MascotParamsFiles deprecated
  def self.getFilenames
    files = MascotParamsFile.getParamsFiles
    filenames = []
    files.each do |file|
      filenames << file.filename

    end
    return filenames
  end

  def self.getContents(fn)
    ps = IO.popen("#{SEQUEST_SSH_PREFIX} cat #{MASCOT_PARAMS}/#{fn}")
    out = ps.read
    ps.close
    return out
    
  end
  

  def self.getTAXONOMY
    list = []
    addtolist = false
    Net::HTTP.start('bioinf.itmat.upenn.edu') do |http|
      response = http.get('/mascot/cgi/get_params.pl')
      #now parse through to build array
      lines = StringIO.new(response.body).readlines
      lines.each do |line|
        if line.strip.eql?('[TAXONOMY]') then
          addtolist = true
          next
        end
        
        if addtolist && line.strip[0,1].eql?('[') then
          addtolist = false
        elsif addtolist then
          list << line.strip unless line.strip.eql?('')
        else
          #just pass through
          
        end
      end

      return list


    end


  end


  def self.getDB
    list = []
    addtolist = false
    Net::HTTP.start('bioinf.itmat.upenn.edu') do |http|
      response = http.get('/mascot/cgi/get_params.pl')
      #now parse through to build array
      lines = StringIO.new(response.body).readlines
      lines.each do |line|
        if line.strip.eql?('[DB]') then
          addtolist = true
          next
        end
        
        if addtolist && line.strip[0,1].eql?('[') then
          addtolist = false
        elsif addtolist then
          list << line.strip unless line.strip.eql?('')
        else
          #just pass through
          
        end
      end

      return list


    end


  end

  def self.getCLE
    list = []
    addtolist = false
    Net::HTTP.start('bioinf.itmat.upenn.edu') do |http|
      response = http.get('/mascot/cgi/get_params.pl')
      #now parse through to build array
      lines = StringIO.new(response.body).readlines
      lines.each do |line|
        if line.strip.eql?('[CLE]') then
          addtolist = true
          next
        end
        
        if addtolist && line.strip[0,1].eql?('[') then
          addtolist = false
        elsif addtolist then
          list << line.strip unless line.strip.eql?('')
        else
          #just pass through
          
        end
      end

      return list


    end


  end



  def self.getMODS
    list = []
    addtolist = false
    Net::HTTP.start('bioinf.itmat.upenn.edu') do |http|
      response = http.get('/mascot/cgi/get_params.pl')
      #now parse through to build array
      lines = StringIO.new(response.body).readlines
      lines.each do |line|
        if line.strip.eql?('[MODS]') then
          addtolist = true
          next
        end
        
        if addtolist && line.strip[0,1].eql?('[') then
          addtolist = false
        elsif addtolist then
          list << line.strip unless line.strip.eql?('')
        else
          #just pass through
          
        end
      end

      return list


    end


  end


  def self.getHIDDEN_MODS
    list = []
    addtolist = false
    Net::HTTP.start('bioinf.itmat.upenn.edu') do |http|
      response = http.get('/mascot/cgi/get_params.pl')
      #now parse through to build array
      lines = StringIO.new(response.body).readlines
      lines.each do |line|
        if line.strip.eql?('[HIDDEN_MODS]') then
          addtolist = true
          next
        end
        
        if addtolist && line.strip[0,1].eql?('[') then
          addtolist = false
        elsif addtolist then
          list << line.strip unless line.strip.eql?('')
        else
          #just pass through
          
        end
      end

      return list


    end


  end


  def self.getINSTRUMENT
    list = []
    addtolist = false
    Net::HTTP.start('bioinf.itmat.upenn.edu') do |http|
      response = http.get('/mascot/cgi/get_params.pl')
      #now parse through to build array
      lines = StringIO.new(response.body).readlines
      lines.each do |line|
        if line.strip.eql?('[INSTRUMENT]') then
          addtolist = true
          next
        end
        
        if addtolist && line.strip[0,1].eql?('[') then
          addtolist = false
        elsif addtolist then
          list << line.strip unless line.strip.eql?('')
        else
          #just pass through
          
        end
      end

      return list


    end


  end





end
