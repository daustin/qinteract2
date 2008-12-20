# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter CASClient::Frameworks::Rails::Filter

  
  def logout
    
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  
  

end
