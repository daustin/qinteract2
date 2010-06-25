namespace :archive do
  desc "Try to find inputs in lims for al projects"
  task :find_inputs => :environment do

    LIMS_SCRIPT_PATH='/mnt/san/lims1'
    LIMS_CURRENT_PATH = '/lims/data_files'
    total = 0
    total_no_lims = 0
    total_no_file = 0
    PipelineAnalysis.find(:all).each do |pa|
      total += 1
      if pa.jobs.empty? || pa.jobs.last.runscript.match(/#{LIMS_SCRIPT_PATH}/).nil?
	total_no_lims += 1
      
      else  
         total_inputs = 0
         total_inputs_found = 0
         files = '' 
         pa.jobs.last.runscript.each_line do |l|
            if l =~ /scp (#{LIMS_SCRIPT_PATH}\/.+) proteomics\@/
               # found a reference to a lims input
               total_inputs += 1
               fname = $1.split('/').last
               # now lets see if we can find the file now..
               o = `find #{LIMS_CURRENT_PATH} -iname #{fname}`               
               total_inputs_found += 1 unless o.empty?
               files += "#{fname},"
            end

         end
         files.chomp!(',')
         unless total_inputs == total_inputs_found
            total_no_file += 1
            puts "#{pa.owner}\t#{pa.pipeline_project.name} => #{pa.name}\t#{pa.created_at}\thttp://bioinf.itmat.upenn.edu/qInteract2/analysis/view/#{pa.id}\t#{files}"
         end

      end


    end
  puts "Out of #{total} analyses,"
  puts "#{total_no_lims} had no reference to the current LIMS repos."
  puts "#{total_no_file} had some or all of their input files missing from the current LIMS repos"

  end
end
