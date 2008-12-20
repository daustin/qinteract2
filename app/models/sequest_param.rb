class SequestParam < ActiveRecord::Base

has_many :sequest_searches
validates_uniqueness_of :filename
  
  #these fields are outputed to the filesystem for use by sequest
  @@fields = ['first_database_name',
              'second_database_name',
              'nucleotide_reading_frame',
              'mass_type_parent',
              'mass_type_fragment',
              'enzyme_info',
              'max_num_internal_cleavage_sites',
              'peptide_mass_tolerance',
              'peptide_mass_units',
              'protein_mass_filter',
              'fragment_ion_tolerance',
              'ion_series',
              'num_results',
              'num_output_lines',
              'num_description_lines',
              'show_fragment_ions',
              'normalize_xcorr',
              'print_duplicate_references',
              'remove_precursor_peak',
              'ion_cutoff_percentage',
              'match_peak_count',
              'match_peak_allowed_error',
              'match_peak_tolerance',
              'max_num_differential_per_peptide',
              'term_diff_search_options',
              'diff_search_options',
              'create_output_files',
              'add_Cterm_peptide',
              'add_Cterm_protein',
              'add_Nterm_peptide',
              'add_Nterm_protein',
              'add_A_Alanine',
              'add_C_Cysteine',
              'add_D_Aspartic_Acid',
              'add_E_Glutamic_Acid',
              'add_F_Phenylalanine',
              'add_G_Glycine',
              'add_H_Histidine',
              'add_I_Isoleucine',
              'add_K_Lysine',
              'add_L_Leucine',
              'add_M_Methionine',
              'add_N_Asparagine',
              'add_O_Ornithine',
              'add_P_Proline',
              'add_Q_Glutamine',
              'add_R_Arginine',
              'add_S_Serine',
              'add_T_Threonine',
              'add_V_Valine',
              'add_W_Tryptophan',
              'add_Y_Tyrosine',
              'add_B_avg_NandD',
              'add_X_LorI',
              'add_Z_avg_QandE',
              'add_J_user_amino_acid',
              'add_U_user_amino_acid' ]
  
  #static enzyme list
  @@enzymes = [['No_Enzyme', 'No_Enzyme 0 0 - -'],
    ['Trypsin(KR)' , 'Trypsin(KR) $ 1 KR -'],
    ['Trypsin(KRLHN)' , 'Trypsin(KRLHN) $ 1 KRLNH -'],
    ['Trypsin(KR/P)' , 'Trypsin(KR/P) $ 1 KR P'],
    ['Trypsin(KRLNH/P)' , 'Trypsin(KRLNH/P) $ 1 KRLNH P'],
    ['Chymotrypsin' , 'Chymotrypsin $ 1 FWYL -'],
    ['Chymotrypsin(FWY)' , 'Chymotrypsin(FWY) $ 1 FWY P'],
    ['Clostripain' , 'Clostripain $ 1 R -'],
    ['Cyanogen_Bromide' , 'Cyanogen_Bromide $ 1 M -'],
    ['IodosoBenzonate' , 'IodosoBenzonate $ 1 W -'],
    ['Proline_Endopept' , 'Proline_Endopept $ 1 P -'],
    ['Staph_Protease' , 'Staph_Protease $ 1 E -'],
    ['Trypsin_K' , 'Trypsin_K $ 1 K P'],
    ['Trypsin_R' , 'Trypsin_R $ 1 R P'],
    ['GluC' , 'GluC $ 1 ED -'],
    ['LysC' , 'LysC $ 1 K -'],
    ['AspN' , 'AspN $ 0 D -'],
    ['Elastase' , 'Elastase $ 1 ALIV P'],
    ['Elastase/Tryp/Chymo' , 'Elastase/Tryp/Chymo $ 1 ALIVKRWFY P']
    
  ]

  
  def validate
    errors.add_on_empty %w( filename )
    errors.add("filename", "cannot have spaces.") if filename =~ /\s+/
  end





  def initialize (params=nil)
    # first call super so that all the attributes are available. set params to default if nothing has been set.

    if params.nil? then 
      params = { :enzyme_limits => 1,
        :ion_series_A => 0,
        :ion_series_B => 0,
        :ion_series_C => 1,
        :ion_series_Y => 1,
        :ion_series_Z => 0,
        :term_diff_search_options_C => "0.000", 
        :term_diff_search_options_N => "0.000",
        :diff_search_options_1_label => 'S',
        :diff_search_options_1_mass => '0.000',
        :diff_search_options_2_label => 'C',
        :diff_search_options_2_mass => '0.000',
        :diff_search_options_3_label => 'M',
        :diff_search_options_3_mass => '0.000',
        :diff_search_options_4_label => 'X',
        :diff_search_options_4_mass => '0.000',
        :diff_search_options_5_label => 'T',
        :diff_search_options_5_mass => '0.000',
        :diff_search_options_6_label => 'Y',
        :diff_search_options_6_mass => '0.000',
        :create_output_files => '1',
        :max_num_internal_cleavage_sites => '2',
        :peptide_mass_tolerance => '2.000',
        :num_output_lines => '10',
        :num_results => '250',
        :num_description_lines => '15',
        :normalize_xcorr => '0',
        :ion_cutoff_percentage => '0.000',
        :peptide_mass_units => "0",
        :nucleotide_reading_frame => "0",
        :mass_type_parent => "0",
        :mass_type_fragment => "0",
        :show_fragment_ions => '0',
        :print_duplicate_references => "0",
        :fragment_ion_tolerance => '0.0',
        :remove_precursor_peak => "0",
        :protein_mass_filter => "0 0",
        :match_peak_count => "0",
        :match_peak_allowed_error => "1",
        :match_peak_tolerance => "1",
        :create_output_files => "1",
        :max_num_differential_per_peptide => "3",
        :add_Cterm_peptide => "0.00000",
        :add_Cterm_protein => "0.00000",
        :add_Nterm_peptide => "0.00000",
        :add_Nterm_protein => "0.00000",
        :add_Nterm_protein => "0.00000",
        :add_A_Alanine => "0.00000",
        :add_C_Cysteine => "0.00000",
        :add_D_Aspartic_Acid => "0.00000",
        :add_E_Glutamic_Acid => "0.00000",
        :add_F_Phenylalanine => "0.00000",
        :add_G_Glycine => "0.00000",
        :add_H_Histidine => "0.00000",
        :add_I_Isoleucine => "0.00000",
        :add_K_Lysine => "0.00000",
        :add_L_Leucine => "0.00000",
        :add_M_Methionine => "0.00000",
        :add_N_Asparagine => "0.00000",
        :add_O_Ornithine => "0.00000",
        :add_P_Proline => "0.00000",
        :add_Q_Glutamine => "0.00000",
        :add_R_Arginine => "0.00000",
        :add_S_Serine => "0.00000",
        :add_T_Threonine => "0.00000",
        :add_V_Valine => "0.00000",
        :add_W_Tryptophan => "0.00000",
        :add_Y_Tyrosine => "0.00000",
        :add_B_avg_NandD => "0.00000",
        :add_X_LorI => "0.00000",
        :add_Z_avg_QandE => "0.00000",
        :add_J_user_amino_acid => "0.00000",
        :add_U_user_amino_acid => "0.00000"     }

    end



    super(params)


    self.diff_search_options = self.getDiffSearchOptions
    # we don't want to set enzyme info here
    # self.enzyme_info = self.getEnzymeInfo
    self.term_diff_search_options = self.getTermDiffSearchOptions
    self.ion_series = self.getIonSeries

    puts 'finished initialize'

    
  end


  def fields
    return @@fields
  end

  def enzymes
    return @@enzymes
  end


  #reads and parses given array of lines. loads associated class vars. 

  def importVars list
    puts list
 #    puts instance_variables
    puts "attribs:"
 #  puts attributes_names()
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

    file = "[SEQUEST]\r\n"
    
    @@fields.each do |v|
        
      file += "#{v} = #{prepVarForFile(v)}\r\n"

    end

    return file

  end


  def prepVarForFile(v)
    #compute enzymes limits, ion series and c,t term diff mods, and other diff mods. 
    tempstr = ''
    if ! v.match('enzyme_info').nil? then

      tempstr = self.getEnzymeInfo
      
    elsif ! v.match('ion_series').nil? then

      tempstr = self.getIonSeries

    elsif ! v.match('term_diff_search_options').nil? then
      tempstr = self.getTermDiffSearchOptions
      
    elsif ! v.match('diff_search_options').nil? then
    
      tempstr = self.getDiffSearchOptions
      
    else
      
      tempstr = self[v] unless self[v].nil?
      
    end
    

    return tempstr

  end

  def parseImportLine(line)
    
    if ! (line[0,1].eql?("[") || line.empty?) then
      temparray = line.split('=')
      if(temparray.length>1) then
        #need to parse out from line and populate vars for special cases
        if temparray[0].strip.eql?('enzyme_info') then
          self.setEnzymeInfo(temparray[1])

        elsif temparray[0].strip.eql?('ion_series') then
          self.setIonSeries(temparray[1])

        elsif temparray[0].strip.eql?('term_diff_search_options') then
          self.setTermDiffSearchOptions(temparray[1])

        elsif temparray[0].strip.eql?('diff_search_options') then
          self.setDiffSearchOptions(temparray[1])
                    
        else
          
          self["#{temparray[0].strip}"]="#{temparray[1].strip}"
          puts "#{temparray[0].strip} = #{self[temparray[0].strip]}"
          
        end
        
        
      end
      
    end 
  end
  

  #parses and saves diff search options
  def setDiffSearchOptions(dfo = nil)
    return if dfo.nil?
    diffarray = dfo.strip.split(' ')
    
    self.diff_search_options_1_mass = diffarray[0] if diffarray.size > 0
    self.diff_search_options_1_label = diffarray[1] if diffarray.size > 0
    self.diff_search_options_2_mass = diffarray[2] if diffarray.size > 2
    self.diff_search_options_2_label = diffarray[3] if diffarray.size > 2
    self.diff_search_options_3_mass = diffarray[4] if diffarray.size > 4
    self.diff_search_options_3_label = diffarray[5] if diffarray.size > 4
    self.diff_search_options_4_mass = diffarray[6] if diffarray.size > 6
    self.diff_search_options_4_label = diffarray[7] if diffarray.size > 6
    self.diff_search_options_5_mass = diffarray[8] if diffarray.size > 8
    self.diff_search_options_5_label = diffarray[9] if diffarray.size > 8
    self.diff_search_options_6_mass = diffarray[10] if diffarray.size > 10
    self.diff_search_options_6_label = diffarray[11] if diffarray.size > 10
    
    self.diff_search_options = dfo

  end

  #builds diff option field for  file
  def getDiffSearchOptions()
    tempstr = ''
    temphash = { 1 => 'S', 2 => 'C', 3 => 'M', 4 => 'X', 5 => 'T', 6 => 'Y' }
    
    1.upto(6) do |i|
      tempmass = self["diff_search_options_#{i}_mass"]
      templabel = self["diff_search_options_#{i}_label"].strip
      if tempmass.nil? then
        tempstr += "0.000 "
      else 
        tempstr += "#{tempmass} "
      end
      
      if templabel.empty? || templabel.nil? then
        tempstr += "#{temphash[i]} "
      else 
        tempstr += "#{templabel} "
      end
      
    end
    return tempstr
  end


  #parses and saves term diff options
  def setTermDiffSearchOptions(tfo = nil)
    return if tfo.nil?
    diffarray = tfo.strip.split(' ')
    if diffarray.size > 1 then
      self.term_diff_search_options_C = diffarray[0]
      self.term_diff_search_options_N = diffarray[1]
    end
    self.term_diff_search_options = tfo

  end

  #builds term diff option field for file
  def getTermDiffSearchOptions()
    
    tempstr = "#{self.term_diff_search_options_C ||= '0.0000'} #{self.term_diff_search_options_N ||= '0.0000'}"
    return tempstr

  end

  
  #parses and saves enzyme info
  def setEnzymeInfo(eo = nil)
    return if eo.nil?
    strarray = eo.strip.split(' ')
    self.enzyme_limits = strarray[1]
    setstr = eo.strip
    setstr[setstr.index(' ')+1] = '$'
    
    self.enzyme_info="#{setstr}"

  end


  def getEnzymeInfo()
    
    tempstr = self.enzyme_info.sub(/\$/, self.enzyme_limits)
    return tempstr
  end
  
  #parses and saves ion series
  def setIonSeries(is = nil)
    return if is.nil?
    #pick out all the letters
    ionarray = is.strip.split(' ')
    if ionarray.size >= 12 then
      self.ion_series_A = ionarray[0]
      self.ion_series_B = ionarray[1]
      self.ion_series_Y = ionarray[2]
      self.ion_series_C = ionarray[5] if ionarray[5].eql?('1.0')
      self.ion_series_Z = ionarray[11] if ionarray[11].eql?('1.0')
    end
    self.ion_series="#{is.strip}"
    
  end


  def getIonSeries()
    
    tempstr = "#{self.ion_series_A} #{self.ion_series_B} #{self.ion_series_Y} #{self.ion_series_A}.0 #{self.ion_series_B}.0 #{self.ion_series_C}.0 0.0 0.0 0.0 0.0 #{self.ion_series_Y}.0 #{self.ion_series_Z}.0 "
    return tempstr
  end

  


  # returns an array of SequestParamsFiles
  def self.getParamsFiles
    files = []
    ps = IO.popen("#{SEQUEST_SSH_PREFIX} ls -1 #{SEQUEST_PARAMS}")
    fn = ps.readlines
    fn.each do |name| 
  
      temp = SequestParamsFile.new({:filename => name.chomp})
      files << temp
    end
    ps.close
   return files

  end

  # returns an array of the filenames for SequestParamsFiles
  def self.getFilenames
    files = SequestParamsFile.getParamsFiles
    filenames = []
    files.each do |file|
      filenames << file.filename

    end
    return filenames
  end

  def self.getContents(fn)
    ps = IO.popen("#{SEQUEST_SSH_PREFIX} cat #{SEQUEST_PARAMS}/#{fn}")
    out = ps.read
    ps.close
    return out
    
  end
  



end
