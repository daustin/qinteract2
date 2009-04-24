
class ScriptGen
  
  
  def initialize
    
  end
  
  
  def self.runscript(job, rawfile, limsfiles)
    #job is the job object
    #rawfile is a string that is a single rawfile on the sequest server. it shows that the script is being generated for a single rawfile.
    #limsfiles is an array of filepaths to scp to the rawdirectory before search

    runscript = "echo BEGIN EXECUTION - `date`\n"
    runscript += "set -o verbose #echo on\n\n"
    
    #HERE IS WHERE WE SET UP THE WORKING DIRECTORY ON THE SEQUEST SERVER
    
    #first we take care of lims transfer
    if ! limsfiles.nil?
      #first make the raw directory
      runscript += "#{SEQUEST_SSH_PREFIX} mkdir -p #{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}\n\n" if job.sequest_search
      runscript += "#{SEQUEST_SSH_PREFIX} mkdir -p #{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}\n\n" if job.mascot_search
      
      for i in 0...limsfiles.size
        
        runscript += "scp #{limsfiles[i]} #{SEQUEST_LOGIN}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/\n\n" if job.sequest_search
        runscript += "scp #{limsfiles[i]} #{SEQUEST_LOGIN}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/\n\n" if job.mascot_search
      
        
      end
      
    end
    
    #HERE WE DO AN EXTRACT_DTA RUN

    if job.extract_dta
      runscript += extract_dta_script(job.extract_dta)

    end

    #HERE WE DO A COMBION  FILTER

    if job.combion_filter

      runscript += combion_filter_script(job.combion_filter)
      

    end

    if job.mscluster

      runscript += mscluster_script(job.mscluster)
      

    end


    #first take care of sequest settings
    if job.sequest_search

      runscript += sequest_script(job.sequest_search)
      
         
    end



    #now we take care the mascot search
   
    if job.mascot_search

      runscript += mascot_script(job.mascot_search)
      
   
      
    end




    #now we take care of analysis settings
    if job.analysis_setting
      
      #need to get working directory based on user input
      #make the two directories
      
      runscript += "umask 0002\n\n"
      
      if job.analysis_setting.local_swap == "1"
        @work_dir = "#{PROJECT_TMP_ROOT}/#{job.pipeline_analysis.path}"
        runscript += "mkdir -p #{@work_dir}\n\n"
        runscript += "chmod a+rwx #{@work_dir}\n\n"
      else
        @work_dir = "#{PROJECT_ROOT}/#{job.pipeline_analysis.path}"
      end
      
      #now lets move files if necessary
     
      
      if ! rawfile.nil?
        #move single file, note here that this job doesn' have a 

        #check file extensions
        
        rawfile.chomp!
        
        if rawfile.downcase =~ /\.raw/i then
          @fnprefix = rawfile[0..-5]
        elsif rawfile.downcase =~ /\.mzxml/i then
          
          @fnprefix = rawfile[0..-7]
          
        else
          @fnprefix = rawfile
          
        end

        runscript += "#{SEQUEST_SCP_PREFIX}:#{@fnprefix}.tgz #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{@fnprefix}.mzXML #{@work_dir}/\n\n"
        
        @tempprefix = @fnprefix.slice(0...@fnprefix.rindex('/'))
        runscript += "#{SEQUEST_SCP_PREFIX}:#{@tempprefix}/*.pXML #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{@tempprefix}/*.log #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{@tempprefix}/*.html #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{@tempprefix}/*.htm #{@work_dir}/\n\n"

        #now we run specifics for sequest and mascot single file

        if job.analysis_setting.dataset_type.eql?("Sequest")
           runscript += "#{SEQUEST_SCP_PREFIX}:#{@tempprefix}/sequest.params #{@work_dir}/\n\n" 

        elsif job.analysis_setting.dataset_type.eql?("Mascot")
          runscript += "#{SEQUEST_SCP_PREFIX}:#{@tempprefix}/mascot.par #{@work_dir}/\n\n"
          runscript += "#{SEQUEST_SCP_PREFIX}:#{@fnprefix}/datlist.txt #{@work_dir}/\n\n"
          
          #for each file in datlist, loop through and copy to work directory. 
                    
          runscript += "while read inputline\n"
          runscript += "do\n"
          runscript += "datfile=\"$(echo $inputline | cut -d= -f1)\"\n"
          runscript += "rawfile=\"$(echo $inputline | cut -d= -f2)\"\n"
          runscript += "cp -v #{MASCOT_DATA}/$datfile #{@work_dir}\n"
          runscript += "tempname=\"$(echo $datfile | cut -d/ -f2)\"\n"
          runscript += "done < #{@work_dir}/datlist.txt\n"
          
        else
          # do nothing
        end

        # common cleanup stuff
        runscript += "#{SEQUEST_SSH_PREFIX} rm -f #{@fnprefix}.tgz\n\n"
        runscript += "#{SEQUEST_SSH_PREFIX} rm -f #{@fnprefix}.mzXML\n\n"
        runscript += "#{SEQUEST_SSH_PREFIX} rm -rf #{@fnprefix}/\n\n"

        

      elsif job.sequest_search
        
        #move files from sequest server
        
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.tgz #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.mzXML #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.pXML #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.params #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.log #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.html #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.htm #{@work_dir}/\n\n"

 
        #cleanup the files on the sequest server.
        runscript += "#{SEQUEST_SSH_PREFIX} rm -f #{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.tgz\n\n"
        runscript += "#{SEQUEST_SSH_PREFIX} rm -f #{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*.mzXML\n\n"
        runscript += "#{SEQUEST_SSH_PREFIX} rm -rf #{SEQUEST_RESULTS}/#{job.sequest_search.raw_dir}/*/\n\n"

      elsif job.mascot_search
        
        #move files from sequest server
        

        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.tgz #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.mzXML #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.pXML #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.par #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/datlist.txt #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.log #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.html #{@work_dir}/\n\n"
        runscript += "#{SEQUEST_SCP_PREFIX}:#{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.htm #{@work_dir}/\n\n"

        #for each file in datlist, loop through and copy to work directory. 
        
        # runscript += "for file in `cat #{@work_dir}/datlist.txt`; do cp -v #{MASCOT_DATA}/$file #{@work_dir};done  \n\n"
 
        runscript += "while read inputline\n"
        runscript += "do\n"
        runscript += "datfile=\"$(echo $inputline | cut -d= -f1)\"\n"
        runscript += "rawfile=\"$(echo $inputline | cut -d= -f2)\"\n"
        runscript += "cp -v #{MASCOT_DATA}/$datfile #{@work_dir}\n"
        runscript += "tempname=\"$(echo $datfile | cut -d/ -f2)\"\n"
        runscript += "done < #{@work_dir}/datlist.txt\n"


        #cleanup the files on the sequest server.
        runscript += "#{SEQUEST_SSH_PREFIX} rm -f #{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.tgz\n\n"
        runscript += "#{SEQUEST_SSH_PREFIX} rm -f #{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*.mzXML\n\n"
        runscript += "#{SEQUEST_SSH_PREFIX} rm -rf #{SEQUEST_RESULTS}/#{job.mascot_search.raw_dir}/*/\n\n"
       
      end
      
      runscript += analysis_script(job.analysis_setting)
      
      #here we move things around and cleanup 
      if job.analysis_setting.local_swap == "1"
        runscript += "chmod -R 0775 *\n\n"
        runscript += "cp *.* #{PROJECT_ROOT}/#{job.pipeline_analysis.path}\n\n"
       
        
	if BIOSTORE_SSH_PREFIX.strip == ""
          runscript += "for file in #{PROJECT_ROOT}/#{job.pipeline_analysis.path}/*.tgz; do tar -pzx -C #{PROJECT_ROOT}/#{job.pipeline_analysis.path} -f $file;done\n\n" if job.mascot_search.nil?
          
	else 
          
          runscript += "#{BIOSTORE_SSH_PREFIX} 'for file in #{BIOSTORE_ROOT}/#{job.pipeline_analysis.path}/*.tgz; do tar -pzx -C #{BIOSTORE_ROOT}/#{job.pipeline_analysis.path} -f $file;done ' \n\n" if job.mascot_search.nil?
          
	end
        
        runscript += "rm -rf #{PROJECT_TMP_ROOT}/#{job.pipeline_analysis.path}\n\n"
      else
        runscript += "chmod 0775 *.*\n\n"
        runscript += "chmod 0775 */ \n\n"
      end 
      
      #finish
      runscript += "cd #{PROJECT_ROOT}/#{job.pipeline_analysis.path}\n\n"
      runscript += "chmod 0777 */ \n\n"
      runscript += "perl -S changePath.pl scratch data '*.html'\n\n"
      runscript += "perl -S changePath.pl scratch data '*.xsl'\n\n"
      runscript += "perl -S changePath.pl scratch data '*.xml'\n\n"
      
      runscript += "chmod 0777 *.* \n\n"

      #now we clean up the dirs..

      runscript += "rm -rf */\n\n"

    end
    runscript += "echo END EXECUTION - `date`\n"
    return runscript	
    
    
    
  end
  
  def self.rerunscript(job)
    
    
    
    
    
  end
  
  
  
  
  def self.mergescript(job)
    
    
    
    
  end
  
  
  def self.combion_filter_script(combion_filter)
    runscript = ''
    runscript += "#{SEQUEST_SSH_PREFIX} \"ruby -S runCombionFilter.rb '#{combion_filter.get_url}' #{SEQUEST_RESULTS}/#{combion_filter.raw_dir}\"\n\n"
    return runscript

  end

  def self.mscluster_script(mscluster)
     
    runscript = ''
    runscript +=  "#{SEQUEST_SSH_PREFIX} ruby -S run_mscluster.rb -c #{SEQUEST_RESULTS}/#{mscluster.raw_dir} \n\n"
    return runscript

  end


  def self.extract_dta_script(extract_dta)
    runscript = ''
    # first create the params file ahead of time, then copy in script and run extract in script
    system "mkdir #{TEMP_SHARE}" unless File.exist?("#{TEMP_SHARE}")
    tempfile = File.new("#{TEMP_SHARE}/#{extract_dta.extract_param.filename}_#{extract_dta.extract_param.updated_at.strftime('%Y%m%d%H%M%S')}.pXML", "w+")
    tempfile.write("#{extract_dta.extract_param.exportToFile()}")
    tempfile.close
    #now we copy over the file
    runscript += "scp #{tempfile.path} #{SEQUEST_LOGIN}:#{SEQUEST_RESULTS}/#{extract_dta.raw_dir}/\n\n"
    #now lets run the actual script on the sequest server
      
    #  now we call either decon or mzxml2search depending on which algos was selected
    # also this affects when exactly readraw is run.  decon after, mzxml before. 


    if extract_dta.algorithm.eql?("decon")
      runscript += "#{SEQUEST_SSH_PREFIX} ruby -S run_deconmsn.rb -c #{SEQUEST_RESULTS}/#{extract_dta.raw_dir} -p ./#{File.basename(tempfile.path)} "
      runscript += "--mgf" unless extract_dta.job.mscluster.nil?
      runscript += "\n\n"
      
      runscript += "#{SEQUEST_SSH_PREFIX} runReadw.sh #{SEQUEST_RESULTS}/#{extract_dta.raw_dir} "
      runscript += "p\n\n" 
      
    else
      
      runscript += "#{SEQUEST_SSH_PREFIX} runReadw.sh #{SEQUEST_RESULTS}/#{extract_dta.raw_dir} "
      runscript += "p\n\n" 
      
      runscript += "#{SEQUEST_SSH_PREFIX} ruby -S run_extractmsn.rb -c #{SEQUEST_RESULTS}/#{extract_dta.raw_dir} -p ./#{File.basename(tempfile.path)} "

      runscript += "\n\n"

    end
    
    return runscript

  end


  
  def self.sequest_script(sequest_search)
    
    runscript = ''
    # first create the params file ahead of time, then copy in script and run extract in script
    system "mkdir #{TEMP_SHARE}" unless File.exist?("#{TEMP_SHARE}")
    tempfile = File.new("#{TEMP_SHARE}/#{sequest_search.sequest_param.filename}_#{sequest_search.sequest_param.updated_at.strftime('%Y%m%d%H%M%S')}.params", "w+")
    tempfile.write("#{sequest_search.sequest_param.exportToFile()}")
    tempfile.close
    #now we copy over the file.
    runscript += "scp #{tempfile.path} #{SEQUEST_LOGIN}:#{SEQUEST_RESULTS}/#{sequest_search.raw_dir}/sequest.params\n\n" 
    runscript += "#{SEQUEST_SSH_PREFIX} ./fixPVM.sh\n\n"
    
    runscript += "#{SEQUEST_SSH_PREFIX} runSequestSearch.pl --cluster --cwd #{SEQUEST_RESULTS}/#{sequest_search.raw_dir} \n\n"
    
    runscript += "#{SEQUEST_SSH_PREFIX} cmd /C sqtar #{SEQUEST_RESULTS}/#{sequest_search.raw_dir}\n\n"
    
    return runscript
    
  end
  

  def self.mascot_script(mascot_search)
    
    runscript = ''
    # first create the params file ahead of time, then copy in script and run extract in script
    system "mkdir #{TEMP_SHARE}" unless File.exist?("#{TEMP_SHARE}")
    tempfile = File.new("#{TEMP_SHARE}/#{mascot_search.mascot_param.filename}_#{mascot_search.mascot_param.updated_at.strftime('%Y%m%d%H%M%S')}.par", "w+")
    tempfile.write("#{mascot_search.mascot_param.exportToFile()}")
    tempfile.close
    #now we copy over the file.
    runscript += "scp #{tempfile.path} #{SEQUEST_LOGIN}:#{SEQUEST_RESULTS}/#{mascot_search.raw_dir}/mascot.par\n\n" 
    

    runscript += "#{SEQUEST_SSH_PREFIX} ruby -S runMascotSearch.rb #{SEQUEST_RESULTS}/#{mascot_search.raw_dir} \n\n"    
    return runscript
    
  end



  
  def self.analysis_script(analysis_setting)
    
    
    runscript = ''
    if analysis_setting.local_swap == "1"
      @work_dir = "#{PROJECT_TMP_ROOT}/#{analysis_setting.job.pipeline_analysis.path}"
    else
      @work_dir = "#{PROJECT_ROOT}/#{analysis_setting.job.pipeline_analysis.path}"
    end
    
    runscript += "cd #{PROJECT_ROOT}/#{analysis_setting.job.pipeline_analysis.path}\n\n"
    runscript += "export TEMP_ID=`echo $PBS_JOBID | awk -F. '{ print $1 }'`\n\n"
    runscript += "echo if you can read this then qsub output was not generated correctly. > runPipeline.sh.o$TEMP_ID\n\n"
    runscript += "export TEMP_ID=\n\n"
    
    runscript += "cd #{@work_dir}\n\n"    
    runscript += "chmod 0775 *.*\n\n"

    if analysis_setting.local_swap == "1"
      runscript += "export WEBSERVER_ROOT=#{WEBSERVER_TMP_ROOT}\n\n"
    else
      runscript += "export WEBSERVER_ROOT=#{WEBSERVER_ROOT}\n\n"
    end	

    runscript += "export HOSTNAME=guacamole.itmat.upenn.edu\n\n"

    ## now we look for sequest sepecific things
    
    if analysis_setting.dataset_type == "Sequest"
      
      #unpack
      runscript += "for file in #{@work_dir}/*.tgz; do tar -xf $file; done\n\n"
      
      #now we run xinteract and helper apps.
      
      runscript += "for outdir in `ls -d */ | sed 's/\\\///g'`; do #{BIN_PATH}/Out2XML $outdir 1 -Psequest.params; done\n\n"
      
    end

    #mascot stuff here
    if analysis_setting.dataset_type == "Mascot"
      
      
      # first let's rename the files to their raw equivalents
      runscript += "while read inputline\n"
      runscript += "do\n"
      runscript += "datfile=\"$(echo $inputline | cut -d= -f1)\"\n"
      runscript += "rawfile=\"$(echo $inputline | cut -d= -f2)\"\n"
      runscript += "tempname=\"$(echo $datfile | cut -d/ -f2)\"\n"
      runscript += "mv $tempname $rawfile\n"
      runscript += "done < datlist.txt\n"
      
      runscript += "for datfile in *.dat; do #{BIN_PATH}/Mascot2XML $datfile -D#{DB_ROOT}/#{analysis_setting.prot_db}; done\n\n"


    end


    #common stuff 
    #run xmlupdater
    
    runscript += "perl -S pepXMLDBUpdater.pl -d #{DB_ROOT}/#{analysis_setting.prot_db} *.xml\n\n"
    #run xinteract
    runscript += "for xmlfile in *.xml; do perl -S excludeShort.pl $xmlfile #{analysis_setting.min_length}; done\n\n"    

    runscript += "#{BIN_PATH}/xinteract -Ninteract.xml #{analysis_setting.xinteract_flags} *.xml \n\n"
    
    runscript += "#{BIN_PATH}/ProteinProphet interact.xml interact-prot.xml #{analysis_setting.prophet_flags}\n\n"

    runscript += "#{BIN_PATH}/ProtProphModels.pl -i interact-prot.xml\n\n"
    
    #now we run ebp

    runscript += "perl -S ebp.pl #{analysis_setting.ebp_flags} interact.xml ebp.xml\n\n"
    
    runscript += "chmod 777 *.*\n\n"
    
    
    return runscript
    
    
  end
  
  
  
  
  
end
