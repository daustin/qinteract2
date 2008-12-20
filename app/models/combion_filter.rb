class CombionFilter  < ActiveRecord::Base

belongs_to :job
validates_presence_of :raw_dir

  @@url_prefix = 'https://localhost/cgi-bin/dtacombiner.pl?'

  def initialize (params=nil)

    if params.nil? then

      params = {  
        :precursor_tolerance => 4,
        :num_tolerance => 200,
        :scan_num => 1,
        :percent_tolerance => 3,
        :algorithm => 'ionquest',
        :muquest_threshold => 1.9,
        :ionquest_threshold => 42,
        :check_with_muquest => 'on',
        :ionquest_retest => 48,
        :muquest_retest_threshold => 1.7  }

     


    end

    super(params)

  end


#  'http://ProtUser:!Prot_User_05@localhost/cgi-bin/dtacombiner.pl?directory=subdirtest/datest5&precursor_tolerance=4.0&scan_num=0&scan_tolerance=200&num_tolerance=200&percent_tolerance=3&muquest_threshold=1.9&algorithm=ionquest&ionquest_threshold=42&check_with_muquest=on&ionquest_retest=48&muquest_retest_threshold=1.7&combine=combine_and_delete'

  
  def get_url

    url = ''
    
    #fyi this does not add the directory onto the end, and it always sets combin_and_delete param
    url += "precursor_tolerance=#{self.precursor_tolerance}&scan_num=#{self.scan_num}&scan_tolerance=#{self.scan_tolerance}&num_tolerance=#{self.num_tolerance}&percent_tolerance=#{self.percent_tolerance}&muquest_threshold=#{self.muquest_threshold}&algorithm=#{self.algorithm}&ionquest_threshold=#{self.ionquest_threshold}&check_with_muquest=#{self.check_with_muquest}&ionquest_retest=#{self.ionquest_retest}&muquest_retest_threshold=#{self.muquest_retest_threshold}&combine=combine_and_delete&directory=#{self.raw_dir}"
    
    return url
    


  end

end
