class SequestParamsFile
  
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
  
  #static enzyme list TODO
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



  
  #additional accessors to help with UI
  attr_accessor :filename, 
  :enzyme_limits, 
  :ion_series_A, 
  :ion_series_B, 
  :ion_series_C, 
  :ion_series_Y, 
  :ion_series_Z, 
  :term_diff_search_options_C,
  :term_diff_search_options_N,
  :diff_search_options_1_label, 
  :diff_search_options_1_mass, 
  :diff_search_options_2_label, 
  :diff_search_options_2_mass, 
  :diff_search_options_3_label, 
  :diff_search_options_3_mass, 
  :diff_search_options_4_label, 
  :diff_search_options_4_mass, 
  :diff_search_options_5_label, 
  :diff_search_options_5_mass, 
  :diff_search_options_6_label, 
  :diff_search_options_6_mass

 
  #These are accessors for the file fields
  attr_accessor :first_database_name,
  :second_database_name,
  :nucleotide_reading_frame,
  :mass_type_parent,
  :mass_type_fragment,
  :enzyme_info,
  :max_num_internal_cleavage_sites,
  :peptide_mass_tolerance,
  :peptide_mass_units,
  :protein_mass_filter,
  :fragment_ion_tolerance,
  :num_results,
  :ion_series,
  :num_output_lines,
  :num_description_lines,
  :print_duplicate_references,
  :show_fragment_ions,
  :normalize_xcorr,
  :remove_precursor_peak,
  :ion_cutoff_percentage,
  :match_peak_count,
  :match_peak_allowed_error,
  :match_peak_tolerance,
  :max_num_differential_per_peptide,
  :term_diff_search_options,
  :diff_search_options,
  :create_output_files,
  :add_Cterm_peptide,
  :add_Cterm_protein,
  :add_Nterm_peptide,
  :add_Nterm_protein,
  :add_A_Alanine,
  :add_C_Cysteine,
  :add_D_Aspartic_Acid,
  :add_E_Glutamic_Acid,
  :add_F_Phenylalanine,
  :add_G_Glycine,
  :add_H_Histidine,
  :add_I_Isoleucine,
  :add_K_Lysine,
  :add_L_Leucine,
  :add_M_Methionine,
  :add_N_Asparagine,
  :add_O_Ornithine,
  :add_P_Proline,
  :add_Q_Glutamine,
  :add_R_Arginine,
  :add_S_Serine,
  :add_T_Threonine,
  :add_V_Valine,
  :add_W_Tryptophan,
  :add_Y_Tyrosine,
  :add_B_avg_NandD,
  :add_X_LorI,
  :add_Z_avg_QandE,
  :add_J_user_amino_acid,
  :add_U_user_amino_acid

  


  def initialize (params=nil)
     
    @enzyme_limits = 1
    @ion_series_A = 0
    @ion_series_B = 0
    @ion_series_C = 0
    @ion_series_Y = 0 
    @ion_series_Z = 0
    @term_diff_search_options_C = "0.000"
    @term_diff_search_options_N = "0.000"
    @diff_search_options_1_label = 'S'
    @diff_search_options_1_mass = '0.000'
    @diff_search_options_2_label = 'C'
    @diff_search_options_2_mass = '0.000'
    @diff_search_options_3_label = 'M'
    @diff_search_options_3_mass = '0.000'
    @diff_search_options_4_label = 'X' 
    @diff_search_options_4_mass = '0.000'
    @diff_search_options_5_label = 'T'
    @diff_search_options_5_mass = '0.000'
    @diff_search_options_6_label = 'Y'
    @diff_search_options_6_mass = '0.000'
    @create_output_files = '1'
    
    if ! params.nil? then 
      #loop through and set instance variables
      
      karray = params.keys
      karray.each do |k|
        #puts "@#{k} => #{params[k]}"
        instance_variable_set("@#{k}", "#{params[k]}")


      end


    end
    

    
  end


  def fields
    return @@fields
  end

  def enzymes
    return @@enzymes
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
      #add in the enzyme limits to the enzyme info
      tempstr = instance_variable_get('@'+v).sub(/\$/, @enzyme_limits)
      
    elsif ! v.match('ion_series').nil? then
      
      tempstr = "#{ion_series_A} #{ion_series_B} #{ion_series_Y} #{ion_series_A}.0 #{ion_series_B}.0 #{ion_series_C}.0 0.0 0.0 0.0 0.0 #{ion_series_Y}.0 #{ion_series_Z}.0 "
      
    elsif ! v.match('term_diff_search_options').nil? then
      
      tempstr = "#{@term_diff_search_options_C ||= '0.0000'} #{@term_diff_search_options_N ||= '0.0000'}"
      
    elsif ! v.match('diff_search_options').nil? then

      temphash = { 1 => 'S', 2 => 'C', 3 => 'M', 4 => 'X', 5 => 'T', 6 => 'Y' }
      
      1.upto(6) do |i|
        tempmass = instance_variable_get("@diff_search_options_#{i}_mass").strip
        templabel = instance_variable_get("@diff_search_options_#{i}_label").strip
        if tempmass.empty? || tempmass.nil? then
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

      
    else
      
      tempstr = instance_variable_get('@'+v) unless instance_variable_get('@'+v).nil?
      
    end
    

    return tempstr

  end

  def parseImportLine(line)
    if ! (line[0,1].eql?("[") || line.empty?) then
      temparray = line.split('=')
      if(temparray.length>1) then
        #need to parse out from line and populate vars for special cases
        if temparray[0].strip.eql?('enzyme_info') then
          #read for limits, then replace and set variable
          strarray = temparray[1].strip.split(' ')
          @enzyme_limits = strarray[1]
          setstr = temparray[1].strip
          setstr[setstr.index(' ')+1] = '$'
          instance_variable_set("@#{temparray[0].strip}", "#{setstr}")

        elsif temparray[0].strip.eql?('ion_series') then
          #pick out all the letters
          ionarray = temparray[1].strip.split(' ')
          if ionarray.size >= 12 then
            @ion_series_A = ionarray[0]
            @ion_series_B = ionarray[1]
            @ion_series_Y = ionarray[2]
            @ion_series_C = ionarray[5] if ionarray[5].eql?('1.0')
            @ion_series_Z = ionarray[11] if ionarray[11].eql?('1.0')
          end
          instance_variable_set("@#{temparray[0].strip}", "#{temparray[1].strip}")
                  
          
        elsif temparray[0].strip.eql?('term_diff_search_options') then
          #pick out all the letters 
          diffarray = temparray[1].strip.split(' ')
          if diffarray.size > 1 then
            @term_diff_search_options_C = diffarray[0]
            @term_diff_search_options_N = diffarray[1]
          end
          instance_variable_set("@#{temparray[0].strip}", "#{temparray[1].strip}")

        elsif temparray[0].strip.eql?('diff_search_options') then
          diffarray = temparray[1].strip.split(' ')
          
          @diff_search_options_1_mass = diffarray[0] if diffarray.size > 0
          @diff_search_options_1_label = diffarray[1] if diffarray.size > 0
          @diff_search_options_2_mass = diffarray[2] if diffarray.size > 2
          @diff_search_options_2_label = diffarray[3] if diffarray.size > 2
          @diff_search_options_3_mass = diffarray[4] if diffarray.size > 4
          @diff_search_options_3_label = diffarray[5] if diffarray.size > 4
          @diff_search_options_4_mass = diffarray[6] if diffarray.size > 6
          @diff_search_options_4_label = diffarray[7] if diffarray.size > 6
          @diff_search_options_5_mass = diffarray[8] if diffarray.size > 8
          @diff_search_options_5_label = diffarray[9] if diffarray.size > 8
          @diff_search_options_6_mass = diffarray[10] if diffarray.size > 10
          @diff_search_options_6_label = diffarray[11] if diffarray.size > 10
          
          instance_variable_set("@#{temparray[0].strip}", "#{temparray[1].strip}")
          
        else
          instance_variable_set("@#{temparray[0].strip}", "#{temparray[1].strip}")
         
          
        end
        
        
      end
      
    end 
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
