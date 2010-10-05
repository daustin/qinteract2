class LimsController < ApplicationController
  ###  now uses new lims objects ###
  def list
    if params[:id]
      
      @projects = User.find(params[:id]).projects
    else
      @projects = User.find_by_username(session[:cas_user]).projects
    end
    
    render(:layout => false)
  end
  def login
    #display the login form
    
  end
  def samples
    #display sample from project id
    @samples = Project.find(params[:id]).samples
    render(:layout => false)
  end
  def files
    #display file from sample id
    @files = Project.find(params[:id]).items.find(:all, :conditions => ["lower(attachment_file_name) like ? OR lower(attachment_file_name) like ?", "%.raw", "%.mzxml"] )
    
    @lims_path = DATAFILE_PATH_PREFIX
    render(:layout => false)
  end
end
