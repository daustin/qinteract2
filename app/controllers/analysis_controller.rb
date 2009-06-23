class AnalysisController < ApplicationController
  require "tpp_file"
  require "yaml"
  require 'net/http'

  def index
    list
    render :action => 'list'
  end
  #  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  
  def view
    @analysis = PipelineAnalysis.find(params[:id])
    @datlist = IO.readlines("#{QINTERACT_PROJECT_ROOT}/#{@analysis.path}/datlist.txt") if File.exist?("#{QINTERACT_PROJECT_ROOT}/#{@analysis.path}/datlist.txt")
    
  end

  def add_params
      render(:layout => false)

  end   

  def list_pi
    comet_server = "guacamole.itmat.upenn.edu"
    comet_uri = "/tpp/cgi-bin/comet-fastadb.cgi"

    @analysis = PipelineAnalysis.find(params[:id])
    @pilist = []
    #for each accession, get pi info via http request. then print out gi and pi numbers
    
    fn = "#{QINTERACT_PROJECT_ROOT}/#{@analysis.path}/interact-prot.xml"
    ps = File.open(fn)
    ps.each do |line|
      
      rgx = /protein_name=\"(\S+)\"/
      if (line =~ rgx)then
        gi = "#{$1}"
         # @pilist << "#{gi}"
        response = Net::HTTP.get_response(comet_server, "#{comet_uri}?Ref=#{gi}&Db=#{DB_ROOT}/#{@analysis.jobs[0].analysis_setting.prot_db}")
         

       response.body.scan(%r{AVG.*pI: (\S+)}m) do |pi|

          @pilist << "#{gi}     #{pi}"

        end
        
      end
       



    end

    
    render(:layout => false)



  end

  
  def create_params
      @xflags = params[:xinteractoptions] ||= ''
      @pflags = params[:prophetoptions] ||= ''
      @eflags = params[:ebpoptions] ||= ''

      render(:layout => false)

  end   

  def count_peptides
    @analysis = PipelineAnalysis.find(params[:id])
    @peptidehash = []
    #here's where we loop through each fraction and add the fraction name and count to the list. 
    fn = "#{QINTERACT_PROJECT_ROOT}/#{@analysis.path}/interact.xml"
    f = TPP::PepXML.new(fn)  if ! File.exist?(fn+".idx")
    f = TPP::PepXML.new(fn,fn+".idx")
    f.parsedump_run_summary_index(fn+".sidx")

    @summary_counts = YAML::load(File.open(fn+".sidx"))
    
    render(:layout => false)

  end

  def list
    #takes an id param. lists all analyses for a given pipeline_project
    @analyses = PipelineProject.find(params[:id]).pipeline_analyses
    @project_id = params[:id]
    render(:layout => false)
  end
  
  def load_dir
    @setting = params[:setting] ||= 'sequest_search'
    @cur_dir = RawDir.new
    @cur_dir.createInstance(params[:rel])
    @raw_dirs = RawDir.getRawDirs(params[:rel])
    #print @raw_dirs.to_s
    render(:layout => false)
  end

  def zip_prep
    #creates archive without setting archive flag or removiing directory
    analysis = PipelineAnalysis.find(params[:id])
    #first we look to see if the job is still running
    ps = IO.popen("qstat #{analysis.archive_qid}.bap 2>&1")
    pstr = ps.gets
    ps.close
    if pstr =~ /Unknown/
      #now submit the archive script
      Dir.chdir("#{PROJECT_ROOT}/#{analysis.pipeline_project.path}") do
        runfile = File.new("zip_#{analysis.id}.sh", "w+", 0775)
        runfile.write( "cd #{PROJECT_ROOT}/#{analysis.pipeline_project.path}\n\n")
        unless File.exist?("#{ARCHIVE_ROOT}/archive_#{analysis.id}.tgz") then
          runfile.write("tar --gzip -pcvf archive_#{analysis.id}.tgz #{analysis.owner}_#{analysis.id}/\n\n")
          runfile.write("mv archive_#{analysis.id}.tgz #{ARCHIVE_ROOT}\n\n")
        end
        runfile.close
        # now get the qsub id
        ps = IO.popen("#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe zip_#{analysis.id}.sh", "r+")
        out = ps.gets        
        if ! out.nil? && out.match(/^\d.*/)
          sa = out.split('.')
          analysis.archive_qid = sa[0]
          flash[:notice] = "Archive task submimtted. Please allow several minutes for the job to run: Job #{sa[0]}"
        else
          analysis.archive_qid= 0
          flash[:notice] = 'Archive task could not be submitted. Contact your administrator.'
        end    
        ps.close
      end
    else
      # job is still running
      flash[:notice] = "Could not perform task because job #{analysis.archive_qid} is still running"      
    end
    redirect_to :action => "view", :id => "#{analysis.id}"

  end

  def zip
    analysis = PipelineAnalysis.find(params[:id])
    #first we look to see if the job is still running
    ps = IO.popen("qstat #{analysis.archive_qid}.bap 2>&1")
    pstr = ps.gets
    ps.close
    if pstr =~ /Unknown/
      analysis.archived = 1
      #now submit the archive script
      Dir.chdir("#{PROJECT_ROOT}/#{analysis.pipeline_project.path}") do
        runfile = File.new("zip_#{analysis.id}.sh", "w+", 0775)
        runfile.write( "cd #{PROJECT_ROOT}/#{analysis.pipeline_project.path}\n\n")
        unless File.exist?("#{ARCHIVE_ROOT}/archive_#{analysis.id}.tgz") then
          runfile.write("tar --gzip -pcvf archive_#{analysis.id}.tgz #{analysis.owner}_#{analysis.id}/\n\n")
          runfile.write("mv archive_#{analysis.id}.tgz #{ARCHIVE_ROOT}\n\n")
        end
        runfile.write("rm -rf #{analysis.owner}_#{analysis.id}/\n\n")
        runfile.close
        # now get the qsub id
        ps = IO.popen("#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe zip_#{analysis.id}.sh", "r+")
        out = ps.gets        
        if ! out.nil? && out.match(/^\d.*/)
          sa = out.split('.')
          analysis.archive_qid = sa[0]
          flash[:notice] = "Archive task submimtted. Please allow several minutes for the job to run: Job #{sa[0]}"
        else
          analysis.archive_qid= 0
          flash[:notice] = 'Archive task could not be submitted. Contact your administrator.'
        end    
        ps.close
      end
    else
      # job is still running
      flash[:notice] = "Could not perform task because job #{analysis.archive_qid} is still running"      
    end
    analysis.save    
    redirect_to :action => "view", :id => "#{analysis.id}"
    
    
  end

 def unzip
   analysis = PipelineAnalysis.find(params[:id])
   #first we look to see if the job is still running
   ps = IO.popen("qstat #{analysis.archive_qid}.bap 2>&1")
   pstr = ps.gets
   ps.close
   if pstr =~ /Unknown/
     analysis.archived = 0
     #now submit the unarchive script
     Dir.chdir("#{PROJECT_ROOT}/#{analysis.pipeline_project.path}") do
       runfile = File.new("zip_#{analysis.id}.sh", "w+", 0775)
       runfile.write("cd #{PROJECT_ROOT}/#{analysis.pipeline_project.path}\n\n")
       runfile.write("cp #{ARCHIVE_ROOT}/archive_#{analysis.id}.tgz .\n\n")
       runfile.write("tar --gunzip -xzvf archive_#{analysis.id}.tgz \n\n")
       runfile.write("chmod -R 777 #{analysis.owner}_#{analysis.id}/ \n\n")
       runfile.write("rm ./archive_#{analysis.id}.tgz \n\n")
       runfile.close
       # now get the qsub id
       ps = IO.popen("#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe zip_#{analysis.id}.sh", "r+")
       out = ps.gets        
       if ! out.nil? && out.match(/^\d.*/)
         sa = out.split('.')
         analysis.archive_qid = sa[0]
         flash[:notice] = "Archive task submimtted. Please allow several minutes for the job to run: Job #{sa[0]}"
       else
         analysis.archive_qid= 0
         flash[:notice] = 'Archive task could not be submitted. Contact your administrator.'
       end    
       ps.close
     end
   else
     # job is still running
     flash[:notice] = "Could not perform task because job #{analysis.archive_qid} is still running"      
   end
   analysis.save
   redirect_to :action => "view", :id => "#{analysis.id}"
   
   
   
   
 end


  #need new sequest and new mascot
  #need separate create for sequest and mascot

  def new_sequest

    @dataset_type = 'Sequest'
    @pipeline_project = PipelineProject.find(params[:id])
    @import_job = Job.findByPBS(params[:qsubid].to_i) if ! params[:qsubid].nil?
    @users = User.find(:all, :order => "login")    
    @pipeline_analysis = PipelineAnalysis.new
    @pipeline_analysis.pipeline_project = @pipeline_project
    @pipeline_analysis.pipeline_project_id = @pipeline_project.id
    @pipeline_analysis.owner = @pipeline_project.owner

    @job = Job.new
    if ! @import_job.nil?
      @qsubid = params[:qsubid]
      @job.notify_email = @import_job.notify_email
      if ! @import_job.sequest_search.nil? then
        @sequest_search = @import_job.sequest_search.clone
        @sequest_search.raw_dir = nil
        
      end
      if ! @import_job.combion_filter.nil? then
        @combion_filter = @import_job.combion_filter.clone 
        
      end

      @extract_dta = @import_job.extract_dta.clone if ! @import_job.extract_dta.nil?
      @analysis_setting = @import_job.analysis_setting.clone if ! @import_job.analysis_setting.nil?

    else

        @extract_dta = ExtractDta.new()
        @extract_dta.algorithm = 'extract_msn'
        @combion_filter = CombionFilter.new
        @sequest_search = SequestSearch.new
	@analysis_setting = AnalysisSetting.new
	@analysis_setting.xinteract_flags = '-Ol'
	@analysis_setting.prophet_flags = 'DB_REFRESH MINPROB0.05 EXCLUDE_ZEROS'
	@analysis_setting.ebp_flags = '-m0.05 --nohom -P0.01' 

    end

    @protdb = ProteinDb.getHash
    @sequest_params = SequestParam.find(:all, :order=> "filename")
    @extract_params = ExtractParam.find(:all, :order=> "filename")
    @cur_dir = RawDir.new
    @cur_dir.createInstance('')
    @raw_dirs = RawDir.getRawDirs('')
    
  end
  
  def create_sequest
    
    # here is workaround so that validation will work. uses default settings
    
    # @pipeline_project = PipelineProject.find(params[:id])
    @dataset_type = 'Sequest'
    @users = User.find(:all, :order => "login")
    @pipeline_analysis = PipelineAnalysis.new
    @pipeline_analysis.pipeline_project = @pipeline_project
    @job = Job.new
    @combion_filter = CombionFilter.new
    @extract_dta = ExtractDta.new
    @extract_dta.algorithm = 'decon'
    @sequest_search = SequestSearch.new
    @analysis_setting = AnalysisSetting.new
    @analysis_setting.xinteract_flags = '-Ol'
    @analysis_setting.prophet_flags = 'DB_REFRESH MINPROB0.05 EXCLUDE_ZEROS'
    @analysis_setting.ebp_flags = '-m0.05 --nohom -P0.01' 
    @protdb = ProteinDb.getHash
    @sequest_params = SequestParam.find(:all, :order=> "filename")
    @extract_params = ExtractParam.find(:all, :order=> "filename")
    @cur_dir = RawDir.new
    @cur_dir.createInstance('')
    @raw_dirs = RawDir.getRawDirs('')
    
     
    ##################
    
    #here we have to adjust this method so that extract_dta, combion_filter, sequest_search, analysis_setting are all created independently and then attached to jobs. 


    @pipeline_analysis = PipelineAnalysis.new(params[:pipeline_analysis])
    @pipeline_project_id = @pipeline_analysis.pipeline_project_id

    ##
    @pipeline_project = PipelineProject.find(@pipeline_project_id)
    ##

    @job = Job.new(params[:job])
    @job.qsub_id = 0
    @job.qsub_cmd = 'qsub dummy command'
    @job.runscript = 'echo placeholder'
    
    
    if params[:AnalysisOn]
      @analysis_setting = AnalysisSetting.new(params[:analysis_setting])
      
    end
    #need to determine here whether or not we should separate analyses
    
    
    if ! @pipeline_analysis.save
      render :action => 'new_sequest', :id => @pipeline_project_id and return
    end
    @pipeline_analysis.setPath
    @pipeline_analysis.save
    

    @sequest_search = SequestSearch.new(params[:sequest_search])
        
    @rawfiles = []
    #if this is a lims project, then we need to create our own raw directory.     @rawfiles = []
    if params[:LIMS] == '1'
      @rawfiles = params[:rawfile]
      @sequest_search.raw_dir = "LIMS_TRANSFER/#{session[:cas_user]}/#{Time.now.strftime("%Y%m%d%H%M%S")}"
      
      if @rawfiles.nil? || @rawfiles.empty?
        @pipeline_analysis.destroy
        flash[:notice] = "You have to select at least one raw file or pick a raw folder!"
        render :action => 'new_sequest', :id => @pipeline_project_id and return
      end
      
    end

    #NOW WE ADD THE EXTRACT DTA OBJECT


    @extract_dta = ExtractDta.new(params[:extract_dta])
    @extract_dta.raw_dir = @sequest_search.raw_dir
    if ! @extract_dta.save then
      
      render :action => 'new_sequest', :id => @pipeline_project_id and return
    else
      @job.extract_dta = @extract_dta
    end




    # NOW ADD COMBION_FILTER WHERE APPLICABLE
    
    if ! params[:CombionOn].nil? then
      @combion_filter = CombionFilter.new(params[:combion_filter])
      @combion_filter.raw_dir = @sequest_search.raw_dir
      @combion_filter.combine = 'combine_and_delete'
      if @combion_filter.scan_num == 1 then
        @combion_filter.scan_tolerance = @combion_filter.num_tolerance
      else
        @combion_filter.scan_tolerance = @combion_filter.percent_tolerance
      end

      if ! @combion_filter.save then
        
        render :action => 'new_sequest', :id => @pipeline_project_id and return
      else
        @job.combion_filter = @combion_filter
      end

      @job.combion_filter = @combion_filter
      
    end

      
    if ! params[:MSClusterOn].nil? then
      @mscluster = Mscluster.new({:raw_dir => @sequest_search.raw_dir})
      @job.mscluster = @mscluster
      
    end

      


    @original_name = @pipeline_analysis.name

    @job.pipeline_analysis = @pipeline_analysis
    if ! @job.save
      
      
      @pipeline_analysis.destroy
      render :action => 'new_sequest', :id => @pipeline_project_id and return
    end
    #need to set path and save because it depends on job id
    
    if @analysis_setting
      @analysis_setting.job = @job
      
      if ! @analysis_setting.save
	@pipeline_analysis.destroy
	@job.destroy
        render :action => 'new_sequest', :id => @pipeline_project_id and return
      end
      
    end
    
    @sequest_search.job = @job 
    
    if @sequest_search.save
      #if separate analysis is on, submit for only the first raw file. 
      @files = []
      if params[:SeparateAnalyses]
        #create the runscript
        if @rawfiles.empty?
          #will be deprecated soon this only hapens when not using lims.
          @remps = IO.popen("#{SEQUEST_SSH_PREFIX} ls -1 #{SEQUEST_RESULTS}/#{@sequest_search.raw_dir}/*.raw #{SEQUEST_RESULTS}/#{@sequest_search.raw_dir}/*.RAW")
          @fn = @remps.readlines
          @fn.each do |name| 
            
            @files << name.chomp
            
          end
          @remps.close
          #puts @files.to_s
          @job.runscript = ScriptGen.runscript(@job, "#{@files[0]}", nil)
        else
          #here we have to detrermine the sequest system file name for the first raw file once it gets transferred over. 
          @temp_fname = @rawfiles[0].slice((@rawfiles[0].rindex('/')+1)...@rawfiles[0].length)
          @pipeline_analysis.name = @original_name + " - #{@temp_fname} (main)"
          @pipeline_analysis.save
          @job.runscript = ScriptGen.runscript(@job, "#{SEQUEST_RESULTS}/#{@sequest_search.raw_dir}/#{@temp_fname}", @rawfiles)
          
        end
      else  
        if ! @rawfiles.empty?
          @job.runscript = ScriptGen.runscript(@job, nil, @rawfiles) 
        else
          @job.runscript = ScriptGen.runscript(@job, nil, nil) 
        end
      end

      @job.save
      #create the directory
      File.umask(0000)
      Dir.mkdir("#{QINTERACT_PROJECT_ROOT}/#{@pipeline_analysis.path}", 0777)
      Dir.chdir("#{QINTERACT_PROJECT_ROOT}/#{@pipeline_analysis.path}") do
        #write runscript
        @file = File.new("runPipeline.sh", "w+", 0775)
        @file.write(@job.runscript)
        @file.close
        #submit runscript
        @mail_to = ''
        @mail_to = "-M #{@job.notify_email}" unless @job.notify_email.index('@').nil?
        if params[:SeparateAnalyses]
          @job.qsub_cmd = "#{QSUB_PREFIX} #{QSUB_BATCH}#{PBS_SERVER} -l nodes=1:ppn=2:seq -j oe -m be #{@mail_to} runPipeline.sh"  
        else
          @job.qsub_cmd = "#{QSUB_PREFIX} #{QSUB_BATCH}#{PBS_SERVER} -l nodes=1:ppn=2:seq -j oe -m be #{@mail_to} runPipeline.sh"  
        end
        #puts @job.qsub_cmd
        @ps = IO.popen(@job.qsub_cmd, "r+")
        
        #try to get qsub number and save it, 
        #otherwise through an error and save 0
        @out = @ps.gets        
        if ! @out.nil? && @out.match(/^\d.*/)
          @sa = @out.split('.')
          @job.qsub_id = @sa[0]
          flash[:notice] = 'Your project was successfully created.'
        else
          @job.qsub_id = 0
          flash[:notice] = 'Your project was successfully created but there may have been a problem submitting your job to the queue. Please contact your system administrator.'
        end
        @ps.close

        #now submit auditor:

        file2 = File.new("auditJob.sh", "w+", 0775)
        file2.write("cd #{PROJECT_ROOT}/#{@pipeline_analysis.path}\n\n")
        file2.write("sleep 60\n\n")
        file2.write("wget -O audit.log #{AUDIT_URL}/#{@job.id}\n\n")
        # now we zip it up
        analysis = @pipeline_analysis
        file2.write("cd ..\n\n")
        file2.write("tar --gzip -pcvf archive_#{analysis.id}.tgz #{analysis.owner}_#{analysis.id}/\n\n")
        file2.write("mv archive_#{analysis.id}.tgz #{ARCHIVE_ROOT}\n\n")
        file2.close
        @ps2 = IO.popen("#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} -W depend=afterany:#{@job.qsub_id}#{QSUB_JOB_SUFFIX} auditJob.sh", "r+")
        @ps2.close


        @job.save
        
        
      end
      
      redirect_to :controller => 'project', :action => 'list'
      
      #####
      if params[:SeparateAnalyses] && @job.qsub_id > 0
        
        #here's where we submit the latter projects
        #first we clone the pipeline analysis and the analysis setting
        #note that we don't really need to do error checking because everything was already validated by this point. 
        #but if the lims data is trasferred, we don't have any file list, so we need to build one. 

        if ! @rawfiles.empty?
          @files = []
          for j in 0...@rawfiles.size
            @temp_fname2 = @rawfiles[j].slice((@rawfiles[j].rindex('/')+1)...@rawfiles[j].length)
            @files << "#{SEQUEST_RESULTS}/#{@sequest_search.raw_dir}/#{@temp_fname2}"
          end
          
        end


        for i in 1...@files.size
          @temp_analysis = @pipeline_analysis.clone
          @temp_fname3 = @files[i].slice((@files[i].rindex('/')+1)...@files[i].length)
          @temp_analysis.name = @original_name + " - #{@temp_fname3}"
          @temp_analysis.pipeline_project = @pipeline_analysis.pipeline_project
          @temp_analysis.save
          @temp_analysis.setPath
          @temp_analysis.save
          @temp_job = @job.clone
          @temp_job.pipeline_analysis = @temp_analysis
          @temp_job.save
          @temp_analysis_setting = @analysis_setting.clone
          @temp_analysis_setting.job = @temp_job
          @temp_analysis_setting.save
          
          #puts "Adding extra #{@files[i]}\n\n"
          @temp_job.runscript = ScriptGen.runscript(@temp_job, "#{@files[i]}", nil)
          @temp_job.save
          #create the directory
          File.umask(0000)
          Dir.mkdir("#{QINTERACT_PROJECT_ROOT}/#{@temp_analysis.path}", 0777)
          Dir.chdir("#{QINTERACT_PROJECT_ROOT}/#{@temp_analysis.path}") do
            #write runscript
            @temp_file = File.new("runPipeline.sh", "w+", 0775)
            @temp_file.write(@temp_job.runscript)
            @temp_file.close

            @temp_job.qsub_cmd = "#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} -W depend=afterany:#{@job.qsub_id}#{QSUB_JOB_SUFFIX} runPipeline.sh"
            
            
            
            @ps = IO.popen(@temp_job.qsub_cmd, "r+")
            
            #try to get qsub number and save it, 
            #otherwise through an error and save 0
            @out = @ps.gets        
            if ! @out.nil? && @out.match(/^\d.*/)
              @sa = @out.split('.')
              @temp_job.qsub_id = @sa[0]
              flash[:notice] = 'Your projects were successfully created.'
            else
              @temp_job.qsub_id = 0
              flash[:notice] = 'Your project was successfully created but there may have been a problem submitting your job to the queue. Please contact your system administrator.'
            end
            
            #now submit auditor:

            file2 = File.new("auditJob.sh", "w+", 0775)
            file2.write("cd #{PROJECT_ROOT}/#{@pipeline_analysis.path}\n\n")
            file2.write("sleep 60\n\n")
            file2.write("wget -O audit.log http://guacamole.itmat.upenn.edu/qInteractBypass/job/audit/#{@temp_job.id}\n\n")
            # now we zip it up
            analysis = @pipeline_analysis
            file2.write("cd ..\n\n")
            file2.write("tar --gzip -pcvf archive_#{analysis.id}.tgz #{analysis.owner}_#{analysis.id}/\n\n")
            file2.write("mv archive_#{analysis.id}.tgz #{ARCHIVE_ROOT}\n\n")
            file2.close
            @ps2 = IO.popen("#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} -W depend=afterany:#{@temp_job.qsub_id}#{QSUB_JOB_SUFFIX} auditJob.sh", "r+")
            @ps2.close


          end
          @ps.close
          @temp_job.save
          
        end
        
      end
      
      
      
    else
      
      @combion_filter.destroy if @combion_filter
      @extract_dta.destroy if @extract_dta
      @analysis_setting.destroy if @analysis_setting
      @job.destroy
      @pipeline_analysis.destroy
      render :action => 'new_sequest', :id => @pipeline_project_id and return
    end
    
    
  end

  def new_mascot
    @dataset_type = 'Mascot'
    @pipeline_project = PipelineProject.find(params[:id])
    @import_job = Job.findByPBS(params[:qsubid].to_i) if ! params[:qsubid].nil?
    @users = User.find(:all, :order => "login")
    @pipeline_analysis = PipelineAnalysis.new
    @pipeline_analysis.pipeline_project = @pipeline_project
    @pipeline_analysis.pipeline_project_id = @pipeline_project.id
    @pipeline_analysis.owner = @pipeline_project.owner

    @job = Job.new
    if ! @import_job.nil?
      @qsubid = params[:qsubid]
      @job.notify_email = @import_job.notify_email
      @mascot_search = @import_job.mascot_search.clone
      @mascot_search.raw_dir = nil
     

       if ! @import_job.combion_filter.nil? then
        @combion_filter = @import_job.combion_filter.clone 
         
       end
      
      @extract_dta = @import_job.extract_dta.clone if ! @import_job.extract_dta.nil?
      @analysis_setting = @import_job.analysis_setting.clone if ! @import_job.analysis_setting.nil?
      
    else   
      @extract_dta = ExtractDta.new
      @extract_dta.algorithm = 'extract_msn'
      @mascot_search = MascotSearch.new
      @combion_filter = CombionFilter.new
      @analysis_setting = AnalysisSetting.new
      @analysis_setting.xinteract_flags = '-Ol'
      @analysis_setting.prophet_flags = 'DB_REFRESH MINPROB0.05 EXCLUDE_ZEROS'
      @analysis_setting.ebp_flags = '-m0.05 --nohom -P0.01' 

    end
    
    @protdb = ProteinDb.getHash
    @mascot_params = MascotParam.find(:all, :order=> "filename")
    @extract_params = ExtractParam.find(:all, :order=> "filename")
    @cur_dir = RawDir.new
    @cur_dir.createInstance('')
    @raw_dirs = RawDir.getRawDirs('')

  end


  def create_mascot

    # here is workaround so that validation will work. 
     @dataset_type = 'Mascot'
    # @pipeline_project = PipelineProject.find(params[:id])
    @users = User.find(:all, :order => "login")
    @pipeline_analysis = PipelineAnalysis.new
    @pipeline_analysis.pipeline_project = @pipeline_project
    @job = Job.new 
    @combion_filter = CombionFilter.new
    @mascot_search = MascotSearch.new
    @analysis_setting = AnalysisSetting.new
    @extract_dta = ExtractDta.new
    @extract_dta.algorithm = 'decon'
    @analysis_setting.xinteract_flags = '-Ol'
    @analysis_setting.prophet_flags = 'DB_REFRESH MINPROB0.05 EXCLUDE_ZEROS'
    @analysis_setting.ebp_flags = '-m0.05 --nohom -P0.01' 
    @protdb = ProteinDb.getHash
    @mascot_params = MascotParam.find(:all, :order=> "filename")
    @extract_params = ExtractParam.find(:all, :order=> "filename")
    @cur_dir = RawDir.new
    @cur_dir.createInstance('')
    @raw_dirs = RawDir.getRawDirs('')
    
    ##################
    
    @pipeline_analysis = PipelineAnalysis.new(params[:pipeline_analysis])
    @pipeline_project_id = @pipeline_analysis.pipeline_project_id

    ##
    @pipeline_project = PipelineProject.find(@pipeline_project_id)
    ##

    @job = Job.new(params[:job])
    @job.qsub_id = 0
    @job.qsub_cmd = 'qsub dummy command'
    @job.runscript = 'echo placeholder'
    
    
    if params[:AnalysisOn]
      @analysis_setting = AnalysisSetting.new(params[:analysis_setting])
      
    end
    #need to determine here whether or not we should separate analyses
    
    
    if ! @pipeline_analysis.save
      render :action => 'new_mascot', :id => @pipeline_project_id and return
    end
    @pipeline_analysis.setPath
    @pipeline_analysis.save
    

    @mascot_search = MascotSearch.new(params[:mascot_search])
        
    @rawfiles = []
    #if this is a lims project, then we need to create our own raw directory.     @rawfiles = []
    if params[:LIMS] == '1'
      @rawfiles = params[:rawfile]
      @mascot_search.raw_dir = "LIMS_TRANSFER/#{session[:cas_user]}/#{Time.now.strftime("%Y%m%d%H%M%S")}"


      if @rawfiles.empty?
        @pipeline_analysis.destroy
        flash[:notice] = "You have to select at least one raw file or pick a raw folder."
        render :action => 'new_mascot', :id => @pipeline_project_id and return
      end
      
    end
    
    #NOW WE ADD THE EXTRACT DTA OBJECT

    @job.pipeline_analysis = @pipeline_analysis

    @extract_dta = ExtractDta.new(params[:extract_dta])
    @extract_dta.raw_dir = @mascot_search.raw_dir
    @extract_dta.job = @job
    if ! @extract_dta.save then
      
      render :action => 'new_mascot', :id => @pipeline_project_id and return
    else
      @job.extract_dta = @extract_dta
    end




    # NOW ADD COMBION_FILTER WHERE APPLICABLE
    
    if ! params[:CombionOn].nil? then
      @combion_filter = CombionFilter.new(params[:combion_filter])
      @combion_filter.raw_dir = @mascot_search.raw_dir
      @combion_filter.combine = 'combine_and_delete'
      if @combion_filter.scan_num == 1 then
        @combion_filter.scan_tolerance = @combion_filter.num_tolerance
      else
        @combion_filter.scan_tolerance = @combion_filter.percent_tolerance
      end

      @combion_filter.job = @job

      if ! @combion_filter.save then
        
        render :action => 'new_mascot', :id => @pipeline_project_id and return
      else
        @job.combion_filter = @combion_filter
      end

      @job.combion_filter = @combion_filter
      
    end


    if ! params[:MSClusterOn].nil? then
      @mscluster = Mscluster.new({:raw_dir => @mascot_search.raw_dir})
      @job.mscluster = @mscluster
      
    end




    @original_name = @pipeline_analysis.name
    
    
    @job.pipeline_analysis = @pipeline_analysis
    if ! @job.save
      @pipeline_analysis.destroy
      render :action => 'new', :id => @pipeline_project_id and return
    end
    #need to set path and save because it depends on job id
    
    if @analysis_setting
      @analysis_setting.job = @job
      
      if ! @analysis_setting.save
	@pipeline_analysis.destroy
	@job.destroy
        render :action => 'new_mascot', :id => @pipeline_project_id and return
      end
      
    end
    
    @mascot_search.job = @job 
    
    if @mascot_search.save
      #if separate analysis is on, submit for only the first raw file. 
      @files = []
      if params[:SeparateAnalyses]
        #create the runscript
        if @rawfiles.empty?
          @remps = IO.popen("#{SEQUEST_SSH_PREFIX} ls -1 #{SEQUEST_RESULTS}/#{@mascot_search.raw_dir}/*.raw #{SEQUEST_RESULTS}/#{@mascot_search.raw_dir}/*.RAW")
          @fn = @remps.readlines
          @fn.each do |name| 
            
            @files << name.chomp
            
          end
          @remps.close
          #puts @files.to_s
          @job.runscript = ScriptGen.runscript(@job, "#{@files[0]}", nil)
        else
          #here we have to detrermine the mascot system file name for the first raw file once it gets transferred over. 
          @temp_fname = @rawfiles[0].slice((@rawfiles[0].rindex('/')+1)...@rawfiles[0].length)
          @pipeline_analysis.name = @original_name + " - #{@temp_fname} (main)"
          @pipeline_analysis.save
          @job.runscript = ScriptGen.runscript(@job, "#{SEQUEST_RESULTS}/#{@mascot_search.raw_dir}/#{@temp_fname}", @rawfiles)
          
        end
      else  
        if ! @rawfiles.empty?
          @job.runscript = ScriptGen.runscript(@job, nil, @rawfiles) 
        else
          @job.runscript = ScriptGen.runscript(@job, nil, nil) 
        end
      end

      @job.save
      #create the directory
      File.umask(0000)
      Dir.mkdir("#{QINTERACT_PROJECT_ROOT}/#{@pipeline_analysis.path}", 0777)
      Dir.chdir("#{QINTERACT_PROJECT_ROOT}/#{@pipeline_analysis.path}") do
        #write runscript
        @file = File.new("runPipeline.sh", "w+", 0775)
        @file.write(@job.runscript)
        @file.close
        #submit runscript
        @mail_to = ''
        @mail_to = "-M #{@job.notify_email}" unless @job.notify_email.index('@').nil?
        if params[:SeparateAnalyses]
          @job.qsub_cmd = "#{QSUB_PREFIX} #{QSUB_BATCH}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} runPipeline.sh"  
        else
          @job.qsub_cmd = "#{QSUB_PREFIX} #{QSUB_BATCH}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} runPipeline.sh"  
        end
        #puts @job.qsub_cmd
        @ps = IO.popen(@job.qsub_cmd, "r+")
        
        #try to get qsub number and save it, 
        #otherwise through an error and save 0
        @out = @ps.gets        
        if ! @out.nil? && @out.match(/^\d.*/)
          @sa = @out.split('.')
          @job.qsub_id = @sa[0]
          flash[:notice] = 'Your project was successfully created.'
        else
          @job.qsub_id = 0
          flash[:notice] = 'Your project was successfully created but there may have been a problem submitting your job to the queue. Please contact your system administrator.'
        end
        @ps.close

        #now submit auditor:

        file2 = File.new("auditJob.sh", "w+", 0775)
        file2.write("cd #{PROJECT_ROOT}/#{@pipeline_analysis.path}\n\n")
        file2.write("sleep 60\n\n")
        file2.write("wget -O audit.log http://guacamole.itmat.upenn.edu/qInteractBypass/job/audit/#{@job.id}\n\n")
        # now we zip it up
        analysis = @pipeline_analysis
        file2.write("cd ..\n\n")
        file2.write("tar --gzip -pcvf archive_#{analysis.id}.tgz #{analysis.owner}_#{analysis.id}/\n\n")
        file2.write("mv archive_#{analysis.id}.tgz #{ARCHIVE_ROOT}\n\n")
        file2.close
        @ps2 = IO.popen("#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} -W depend=afterany:#{@job.qsub_id}#{QSUB_JOB_SUFFIX} auditJob.sh", "r+")
        @ps2.close


        @job.save
        
        
      end
      
      redirect_to :controller => 'project', :action => 'list'
      
      #####
      
      if params[:SeparateAnalyses] && @job.qsub_id > 0
        
        #here's where we submit the latter projects
        #first we clone the pipeline analysis and the analysis setting
        #note that we don't really need to do error checking because everything was already validated by this point. 
        #but if the lims data is trasferred, we don't have any file list, so we need to build one. 

        if ! @rawfiles.empty?
          @files = []
          for j in 0...@rawfiles.size
            @temp_fname2 = @rawfiles[j].slice((@rawfiles[j].rindex('/')+1)...@rawfiles[j].length)
            @files << "#{SEQUEST_RESULTS}/#{@mascot_search.raw_dir}/#{@temp_fname2}"
          end
          
        end


        for i in 1...@files.size
          @temp_analysis = @pipeline_analysis.clone
          @temp_fname3 = @files[i].slice((@files[i].rindex('/')+1)...@files[i].length)
          @temp_analysis.name = @original_name + " - #{@temp_fname3}"
          @temp_analysis.pipeline_project = @pipeline_analysis.pipeline_project
          @temp_analysis.save
          @temp_analysis.setPath
          @temp_analysis.save
          @temp_job = @job.clone
          @temp_job.pipeline_analysis = @temp_analysis
          @temp_job.save
          @temp_analysis_setting = @analysis_setting.clone
          @temp_analysis_setting.job = @temp_job
          @temp_analysis_setting.save
          
          #puts "Adding extra #{@files[i]}\n\n"
          @temp_job.runscript = ScriptGen.runscript(@temp_job, "#{@files[i]}", nil)
          @temp_job.save
          #create the directory
          File.umask(0000)
          Dir.mkdir("#{QINTERACT_PROJECT_ROOT}/#{@temp_analysis.path}", 0777)
          Dir.chdir("#{QINTERACT_PROJECT_ROOT}/#{@temp_analysis.path}") do
            #write runscript
            @temp_file = File.new("runPipeline.sh", "w+", 0775)
            @temp_file.write(@temp_job.runscript)
            @temp_file.close

            @temp_job.qsub_cmd = "#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} -W depend=afterany:#{@job.qsub_id}#{QSUB_JOB_SUFFIX} runPipeline.sh"
            
                       
            @ps = IO.popen(@temp_job.qsub_cmd, "r+")
            
            #try to get qsub number and save it, 
            #otherwise through an error and save 0
            @out = @ps.gets        
            if ! @out.nil? && @out.match(/^\d.*/)
              @sa = @out.split('.')
              @temp_job.qsub_id = @sa[0]
              flash[:notice] = 'Your projects were successfully created.'
            else
              @temp_job.qsub_id = 0
              flash[:notice] = 'Your project was successfully created but there may have been a problem submitting your job to the queue. Please contact your system administrator.'
            end
            
            #now submit auditor:

            file2 = File.new("auditJob.sh", "w+", 0775)
            file2.write("cd #{PROJECT_ROOT}/#{@pipeline_analysis.path}\n\n")
            file2.write("wget -O audit.log http://guacamole.itmat.upenn.edu/qInteractBypass/job/audit/#{@temp_job.id}\n\n")
            # now we zip it up
            analysis = @pipeline_analysis
            file2.write("cd ..\n\n")
            file2.write("tar --gzip -pcvf archive_#{analysis.id}.tgz #{analysis.owner}_#{analysis.id}/\n\n")
            file2.write("mv archive_#{analysis.id}.tgz #{ARCHIVE_ROOT}\n\n")
            file2.close
            @ps2 = IO.popen("#{QSUB_PREFIX} #{QSUB_CONCUR}#{PBS_SERVER} -l nodes=1:ppn=2 -j oe -m be #{@mail_to} -W depend=afterany:#{@temp_job.qsub_id}#{QSUB_JOB_SUFFIX} auditJob.sh", "r+")
            @ps2.close
            

 
          end
          @ps.close
          @temp_job.save
          
        end
        
      end
      
      
      
    else
      
      @combion_filter.destroy if @combion_filter
      @extract_dta.destroy if @extract_dta
      @analysis_setting.destroy if @analysis_setting
      @job.destroy
      @pipeline_analysis.destroy
      render :action => 'new_mascot', :id => @pipeline_project_id and return
    end
    

  end




  def delete
    @analysis = PipelineAnalysis.find(params[:id])
    @analyses = @analysis.pipeline_project.pipeline_analyses
    @project_id = @analysis.pipeline_project_id
  
    if ! @analysis.owner.eql?(session[:cas_user]) then
      @alert_message = 'You cannot delete an analysis that you do not own!'
      render(:action => 'list', :layout => false) and return 
    end

    #now we check and make sure that there are no jobs running
    active = false
 
    @analysis.jobs.each { |job|
      #get the qsub id and test to see if it's running
      if job.qsub_id > 0 then
        ps = IO.popen("qstat ")
        ps.each { |line|
          active = true if (line =~ /#{job.qsub_id}\./ && line =~ /\sR\s/)
        }
        
        if active then
          @alert_message = "This analysis cannot be deleted because it is running in the queue (job #{job.qsub_id}).  Either wait till it has finished running or contact your system administrator for further assistance."
          
          break
          
        end
      end
      
      
    }

    @project_id = @analysis.pipeline_project_id
    @analyses = PipelineProject.find(@project_id).pipeline_analyses
    render(:action => 'list', :layout => false) and return false if active
    
    
    @analysis.destroy
    render(:action => 'list', :layout => false)


  end

  def getFile
    @analysis = PipelineAnalysis.find(params[:aid])
    @fn = params[:id]
     render(:layout => false)
  end


end 
