class JobAudit < ActiveRecord::Base


  def raw_file_count
  
    inputfiles = 0
    
    j = Job.find(self.job_id)
    return -1 if j.nil?
    script = j.runscript

    # now enumerate through each line


    script.each do |line|
      # check for raw files
       if (line.downcase =~ /scp\s\/mnt\/san\/lims1\/data_files.+\.raw\sproteomics\@sequest/) then
         inputfiles = inputfiles + 1
       end
       #check for mzmxls
       if (line.downcase =~ /scp\s\/mnt\/san\/lims1\/data_files.+\.mzxml\sproteomics\@sequest/) then

         inputfiles = inputfiles + 1

       end


    end

    return inputfiles

  end


end
