class JobController < ApplicationController

  skip_before_filter CASClient::Frameworks::Rails::Filter, :only => [:audit ]

  def add
  end

  def view
    @job = Job.find(params[:id])
    render(:layout => false)

  end
  
  def output
    @job = Job.find(params[:id])
    render(:layout => false)

  end
  
  def script
    @job = Job.find(params[:id])
    render(:layout => false)
    
  end

  def settings
    @job = Job.find(params[:id])
    render(:layout => false)

  end
  
  def pbsinfo
    @job = Job.find(params[:id])
    render(:layout => false)
  
  end



  def index
  end

  def new
	@test = Time.now
	if ! params[:pipeline_project_id]
	 flash[:notice] = 'ERROR Could not attach job to project!'
        redirect_to  :controller => 'project', :action => 'list'
	else
	 @job = Job.new(:runscript => "test", :pipeline_project_id => params[:pipeline_project_id])
	end
  end

  def create
    @job = Job.new(params[:job])
    if @job.save
      flash[:notice] = 'Job was successfully created.'
      redirect_to :controller => 'project', :action => 'list'
    else
      render :action => 'new'
    end
  end


  def get_extract_params
    @contents = ExtractParamsFile.getContents(params[:id])
    render :action => 'view_params_file', :layout => false

  end

  def audit
    numcpu = 2
    cm = 0
    #audits a job specified by ID
    @job_audit = JobAudit.new
    #first read in file and construct job based on what is read in
    @job = Job.find(params[:id])
    @job_audit.cost_center = @job.pipeline_analysis.owner
    @job_audit.job_title = @job.pipeline_analysis.name
    @job_audit.job_id = @job.id
    @job_audit.cluster_multiple = 0

    #which queue
    if @job.qsub_cmd =~ /concur/ then
      @job_audit.queue = 'concur'
    else
      @job_audit.queue = 'batch'
    end

    outfile = File.open("#{QINTERACT_PROJECT_ROOT}/#{@job.pipeline_analysis.path}/runPipeline.sh.o#{@job.qsub_id}")

    #now read each line and plug in the variables
    incluster = false
    outfile.each{ |line|
      if line =~ /^BEGIN EXECUTION.+/ then
        temptime = line.split('-')
        @job_audit.start_time = temptime[1].strip
      elsif line =~ /^END EXECUTION.+/ then
        temptime = line.split('-')
        @job_audit.end_time = temptime[1].strip
      elsif line =~ /^BEGIN CLUSTER.+/ then
        temptime = line.split('-')
        @job_audit.cluster_start = temptime[1].strip
        incluster = true
      elsif line =~ /^END CLUSTER.+/ then
        temptime = line.split('-')
        @job_audit.cluster_end = temptime[1].strip
        incluster = false
        
      elsif line =~ /jsblade\d/ && incluster then
        cm = cm + numcpu
        
      else 
        
        #do nothing

      end
    }

    @job_audit.cluster_multiple = cm
    
    if @job_audit.save then
      @message = 'Job successfully audited'
    else
      @message = 'Was not successfully audited.  Please contact administrator' 
    end
    
    render(:layout => false)

  end

    



end
