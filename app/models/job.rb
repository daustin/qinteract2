class Job < ActiveRecord::Base

  belongs_to :pipeline_analysis
  has_one :sequest_search
  has_one :mascot_search
  has_one :analysis_setting
  has_one :combion_filter
  has_one :extract_dta
  has_one :mscluster

  validates_presence_of :qsub_id, :qsub_cmd, :runscript

  def output
    @output = ''
    if qsub_id > 0
      @output = IO.read("#{PROJECT_ROOT}/#{pipeline_analysis.path}/runPipeline.sh.o#{qsub_id}") if File.exists?("#{PROJECT_ROOT}/#{pipeline_analysis.path}/runPipeline.sh.o#{qsub_id}")
    end
    return @output

  end

  def pbsinfo
    @pbsinfo = ''
    if qsub_id > 0
      
      @pbsinfo = "QSTAT OUTPUT FOR JOB: #{qsub_id}\n\n"
      @ps = IO.popen("qstat -f #{qsub_id}#{QSUB_JOB_SUFFIX}")
      @pbsinfo += @ps.read
      @ps.close
      @pbsinfo += "\n\n===============================================\n\n"

      @pbsinfo += "TRACEJOB OUTPUT FOR JOB: #{qsub_id}\n\n"
      @ps = IO.popen("#{TRACEJOB_CMD} #{qsub_id}#{QSUB_JOB_SUFFIX}")
      @pbsinfo += @ps.read
      @ps.close

    end
    return @pbsinfo
  end



  def self.findByPBS(qsubid)
      find(:first, :conditions => "qsub_id = #{qsubid}", :order => "created_at DESC")


  end  



end
