class ProjectController < ApplicationController
  
  def list

    if params[:username] && params[:username].eql?('All')
      @projects = PipelineProject.desc
    elsif params[:username] && params[:username] != ""
      @projects = PipelineProject.filterUsername(params[:username])
      @filter = params[:username]
    else
      @projects = PipelineProject.filterUsername(session[:cas_user])
      @filter = session[:cas_user]
    end
    @distinctprojects = PipelineProject.getUsernames
       
  end
  
  def create
    @pipeline_project = PipelineProject.new(params[:pipeline_project])
    @pipeline_project.setPath
    if ! @pipeline_project.save
      flash[:notice] = 'Your project was not created.'
      @projects = PipelineProject.desc
      @distinctprojects = PipelineProject.getUsernames
      render :action => 'list' and return
    else
      #need to make dir
      Dir.mkdir("#{PROJECT_ROOT}/#{@pipeline_project.path}", 0777)
      flash[:notice] = 'Your project was successfully created.'
      redirect_to :action => 'list' 
    end
    
    
  end
  

  
  def delete

    @pipeline_project = PipelineProject.find(params[:id])

    ## first check and make sure that the project is owned by the current user.  
    ## also make sure the analyses are not owned by anyone else as well

    if ! @pipeline_project.owner.eql?(session[:cas_user]) then
      flash[:notice] = 'You can only delete projects that you own!'
      redirect_to :controller => 'project', :action => 'list', :username => params[:username] and return
    end
     
    @check = PipelineAnalysis.find(:all, :conditions =>  "pipeline_project_id = #{params[:id]} AND owner != '#{session[:cas_user]}'")
    
    if ! @check.empty?
      flash[:notice] = 'Your project could not be deleted because it contains one or more analyses that you do not own. Contact your system administrator.'
      redirect_to :controller => 'project', :action => 'list', :username => params[:username] and return
    end

    # first remove directory
    @pipeline_project.pipeline_analyses.each { |anal|
      active = false
      anal.jobs.each { |job|
        #get the qsub id and test to see if it's running
      if job.qsub_id > 0 then
        ps = IO.popen("qstat #{PBS_SERVER}")
        ps.each { |line|
            active = true if line =~ /#{job.qsub_id}\./
            
          }
        
        if active then
          flash[:notice] = 'Your project could not be deleted because one or more analyses are still running.'
          
          break
          
        end
      end
        
        
      }
      
      redirect_to :controller => 'project', :action => 'list', :username => params[:username] and return if active
      
      
      
    }

    
    puts "#{BIOSTORE_SSH_PREFIX} rm -rf #{BIOSTORE_ROOT}/#{@pipeline_project.path}"
    @ps = IO.popen("#{BIOSTORE_SSH_PREFIX} rm -rf #{BIOSTORE_ROOT}/#{@pipeline_project.path}", "r+")
    @ps.close
    @pipeline_project.destroy
    redirect_to :controller => 'project', :action => 'list', :username => params[:username]

  end

end
