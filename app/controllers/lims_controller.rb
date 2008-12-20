class LimsController < ApplicationController
  ###  now uses new lims objects ###
  def list
    @projects = User.find_by_login(session[:cas_user]).projects
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
    @files = Project.find(params[:id]).data_files.find(:all,
                                                       :conditions => ["lower(filesystem_name) like ? OR lower(filesystem_name) like ?", "%.raw", "%.mzxml"] )
    
    @lims_path = DATAFILE_PATH_PREFIX
    render(:layout => false)
  end
end
