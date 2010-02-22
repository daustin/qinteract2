class JobAudit < ActiveRecord::Base


  def raw_file_count
  
    inputfiles = 0
    return 'UNKNOWN' unless Job.exists?(:id => self.job_id)
    j = Job.find(self.job_id)
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
