class MainController < ApplicationController

  def index
	
  end


  def current_queue

    @out = "CURRENT QSTAT OUTPUT\n\n"
    @ps = IO.popen("/usr/local/torque/bin/qstat #{PBS_SERVER}")

    @ps.each do |cout|
            
      ## here we check for some job info
      if cout =~ /^\d+\..+/ then
        ## now get the job information and find some info about the job
        sa = cout.split('.')
        jn = sa[0]
        
        j = Job.find(:first, :conditions => "qsub_id = #{jn}")
        # j = jobs[0] unless jobs.empty?
  
        if ! j.nil? then
          if j.pipeline_analysis.nil?
		user = 'UNKNOWN'
	  else
	          user = j.pipeline_analysis.owner
	  end
          inputfiles = 0
          
          
          
          
          script = j.runscript
          
          # now enumerate through each line
          
            script.each do |line|
            if (line.downcase =~ /scp\s\/mnt\/san\/lims1\/data_files.+\.raw\sproteomics\@sequest/) then
              inputfiles = inputfiles + 1
            end
            if (line.downcase =~ /scp\s\/mnt\/san\/lims1\/data_files.+\.mzxml\sproteomics\@sequest/) then
              inputfiles = inputfiles + 1
            end
          end
          
          #now we put it all together
          
          @out += cout.strip + "    #{user} - #{inputfiles} files\n"
          
          
        else
          
          
          @out += cout
          
        end
        
        
        
        
      else
        
        @out += cout
        
      end
      
      
    end
    
    @ps.close
    
    render(:action => 'status', :layout => false)
    
  end
  

  def nodes_status

      @out = "CURRENT NODES STATUS\n\n"
    @ps = IO.popen("/usr/local/bin/pbsnodes -a")
      @out += @ps.read
      @ps.close
      render(:action => 'status', :layout => false)


  end

  def sequest_status

      @out = "SEQUEST CLUSTER STATUS\n\n"
      @ps =  IO.popen("#{SEQUEST_SSH_PREFIX} ./getPVMInfo.sh")
      @out += @ps.read
      @ps.close
      render(:action => 'status', :layout => false)


  end


  def nodes_db

      @ls_cmd = "ls -1 /usr/database/*.fasta /usr/database/*.faa /usr/database/*.hdr"
      @out = "SEQUEST DATABASES ON NODES\n\n"

      for i in 1...14 

	 @out += "\n\njsblade#{i}:\n"
         @ps = IO.popen("ssh jsblade#{i} #{@ls_cmd}")
	 @out += @ps.read 
         @ps.close

      end


      render(:action => 'status', :layout => false)


  end


  def usage_raw
    @year = params[:id]
    @audits = JobAudit.find(:all, :order => "cost_center, start_time", :conditions => "YEAR(start_time) = #{@year}")


  end

  def sequest_infile_report
    @year = params[:id]
    jobs = Job.find(:all, :conditions => "YEAR(created_at) = #{@year}")
    
    # jobs = Job.find(:all, :conditions => "qsub_id = #{@year}") # test only takes a qsub_id
    
    @inputfiles = 0
    
    jobs.each do |j|
      
      if ! j.sequest_search.nil? then
        script = j.runscript
        
        # now enumerate through each line
        
        
        script.each do |line|
          if (line.downcase =~ /scp\s\/mnt\/san\/lims1\/data_files.+\.raw\sproteomics\@sequest/) then
            
            @inputfiles = @inputfiles + 1
            
          end
          
          if (line.downcase =~ /scp\s\/mnt\/san\/lims1\/data_files.+\.mzxml\sproteomics\@sequest/) then
            
            @inputfiles = @inputfiles + 1
            
          end
          
          
        end
        
      end
      
 
    end
    
 
 
  end
 
 


end
