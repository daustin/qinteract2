class Sample < Asset
  has_and_belongs_to_many :data_files

  ## FIND ALL SAMPLES THAT BELONG TO A GIVEN PROJECT

   def self.getSamples(prodid)

     p = Project.find_by_id(prodid)

     return p.samples

  end

end
