class AnalysisSetting < ActiveRecord::Base
  belongs_to :job
  
  validates_presence_of :dataset_type, :prot_db  

  def validate
    if xinteract_flags =~ /^.*;.*$/
       errors.add(:xinteract_flags, "contains illegal characters")
    end
    if prophet_flags =~ /^.*;.*$/
       errors.add(:prophet_flags, "contains illegal characters")
    end
    if ebp_flags =~ /^.*;.*$/
       errors.add(:ebp_flags, "contains illegal characters")
    end
    

  end



  def test
    return "test"

  end 



end
