class Job < ActiveRecord::Base

  belongs_to :pipeline_analysis

  has_one :sequest_search,
          :dependent => :destroy

  has_one :mascot_search,
          :dependent => :destroy
          
  has_one :analysis_setting,
          :dependent => :destroy

  has_one :combion_filter,
          :dependent => :destroy

  has_one :extract_dta,
          :dependent => :destroy

  has_one :mscluster,
          :dependent => :destroy


  validates_presence_of :qsub_id, :qsub_cmd, :runscript

  #stop job and qudit job in queue
  def before_destroy 
    system "qdel #{self.qsub_id}.bap" if self.qsub_id > 0 
    system "qdel #{self.qsub_id+1}.bap" if self.qsub_id > 0 
  end


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
