class MigrateController < ApplicationController
  
  
  def mascot
    
    # here we need to first find and connect the params file
    #secondly we need to create the extract_dta object and connect that to job and also find and connect the extract params file. 
    
    
    flash[:notice] = ''
    
    
    mascot_searches = MascotSearch.find(:all)
    
    mascot_searches.each do |s|
      
      #first we find each mascot params file and connect it
      tempsp = MascotParam.find(:first, :conditions => "filename = '#{s.params_file.chomp('.par')}'")
      if ! tempsp.nil? then
        
        s.mascot_param = tempsp
        
      else 
        
        flash[:notice] += "There was on or more mascot searches that could not be matched with a params file.<BR>"
        
      end
      
      tempdta = ExtractDta.new
      tempdta.raw_dir = s.raw_dir
      tempdta.job = s.job 
      if tempdta.job.nil? then
        next
      end
      
      tempsp = ExtractParam.find(:first, :conditions => "filename = '#{s.extract_params_file.chomp('pXML')}'")
      if ! tempsp.nil? then
        
        tempdta.extract_param = tempsp
        
      else 
        
        flash[:notice] += "There was one or more extract dta that could not be matched with a params file.<BR>"
        
      end
      
      
      tempdta.save
      s.save
      
    end
    
    
    
  end
  
  

  def sequest

    
    # here we need to first find and connect the params file
    #secondly we need to create the extract_dta object and connect that to job and also find and connect the extract params file. 
    
    flash[:notice] = ''
    
    
    sequest_searches = SequestSearch.find(:all)
    
    sequest_searches.each do |s|
      
      #first we find each sequest params file and connect it
      tempsp = SequestParam.find(:first, :conditions => "filename = '#{s.params_file.chomp('.params')}'")
     
      if (! tempsp.nil?) then
        
        s.sequest_param = tempsp
        
      else 
        
        flash[:notice] += "There was on or more sequest searches that could not be matched with a params file.<BR>"
        
      end
      
      tempdta = ExtractDta.new
      tempdta.raw_dir = s.raw_dir
      tempdta.job = s.job
      
      tempsp = ExtractParam.find(:first, :conditions => "filename = '#{s.extract_params_file.chomp('.pXML')}'")
      if (! tempsp.nil?) then
        
        tempdta.extract_param = tempsp
        
      else 
        
        flash[:notice] += "There was one or more extract dta that could not be matched with a params file.<BR>"
        
      end
      
      
      tempdta.save
      s.save
      
    end
    
    
    
  end
  
  
end  
  
  
  
  
