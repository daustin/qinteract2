#!/usr/bin/env ruby
#
#  Created by Angel Pizarro on 2007-03-12.
#  Copyright (c) 2007. All rights reserved.
module TPP
  class TPPFile < File
    require 'yaml'
    def initialize fn, fidx=nil
      # all files are read only so no bits are passed to File.new
      super(fn)
      @type = self.parse_type(fn)
      if fidx
        
        @idx = YAML::load(File.open(fidx))

      else
        self.parse_index fn
      end
    end

    def dump_index fidx
      @temp = File.open(fidx, "w")
      YAML.dump(@idx, @temp)
      @temp.close
    end

    def parse_type fn
      if File.extname(fn) == ".mzXML"
        return @type = 'MzXML'
      end
      # otherwise grep from start tag
      return @type = (self.read(1000) =~ /msms_pipeline_analysis/ ) ? "PepXML" : "ProtXML"
    end

    def parse_index fn
      # set to beginning and rehash the index
      self.rewind
      @idx = {}
      case @type
      when "MzXML"
        self.parse_mzxml_index
      when "PepXML"
        self.parsedump_pep_index "#{fn}.idx"
      when "ProtXML"
        self.parse_prot_index
      end
    end

    def parse_mzxml_index 
      #TO-DO: must do this later.
    end

    def parse_pep_index fn=nil
      rgx = %r{\<spectrum_query\sspectrum="(\S+)".+index=\"(\d+)\"}
      p = 0
      l = ""
       while (!self.eof?)
        p = self.pos 
        l = self.readline
        if ( l =~ rgx) then 
          STDERR.puts("added peptide number #{$2}")
          @idx["#{$2}"] = {:pos => p}
        end
      end
      STDERR.puts("#{@idx.keys.length}")
    end

    def parsedump_pep_index fn
      rgx = %r{\<spectrum_query\sspectrum="(\S+)".+index=\"(\d+)\"}
      p = 0
      l = ""
      hit = ""
      @index = File.open(fn, "w")
      @index.write("---\n")
      while (!self.eof?)
        p = self.pos 
        l = self.readline
        if ( l =~ rgx) then 
          #STDERR.puts("added peptide number #{$2}")
          @idx["#{$2}"] = {:pos => p}
          if ! fn.nil?
            @index.write("\"#{$2}\": \n  :pos: #{p}\n")
          end
          while (!self.eof?)
            hit=self.readline
            rgx2 = %r{\<search_hit\shit_rank=\"1\"\speptide="(\S+)"}
            if (hit =~ rgx2)then
              #STDERR.puts("#{$1}")
              @index.write("  :peptide: #{$1}\n")
              break
            end
            
          end 
        end
       
      end
      @index.close
    end

    def parsedump_run_summary_index fn
      rgx = %r{\<msms_run_summary\sbase_name="(\S+)".+}
      c = 1
      p = 0
      l = ""
      hit = ""
      @index = File.open(fn, "w")
      @index.write("---\n")
      while (!self.eof?)
        p = self.pos 
        l = self.readline
        if ( l =~ rgx) then 
          #STDERR.puts("added peptide number #{$2}")
          
          if ! fn.nil?
            @index.write("\"#{c}\": \n  :pos: #{p}\n  :base_name: #{$1}\n")
            c += 1
          end
          pepcount = 0
          while (!self.eof?)
            
            hit=self.readline
            rgx2 = %r{\<spectrum_query}
            rgx3 = %r{\<\/msms_run_summary.+}
            if (hit =~ rgx2)then
              #STDERR.puts("found \n")
              pepcount += 1
            elsif (hit =~ rgx3) then
              @index.write("  :peptide_count: #{pepcount}\n")
              pepcount = 0
              break
            else
              #do nothing
            end
            
          end 

        end
      
      end
      @index.close
    end



    def parse_prot_index 
      rgx = %r{\<protein_group\sgroup_number=\"(\d+)\".+probability=\"(\S+)\"}
      p = 0
      l = ""
      while (!self.eof?)
        p = self.pos 
        l = self.readline
        if ( l =~ rgx) then 
          @idx["#{$1}"] = {:pos => p, :probabilty => $2}
        end
      end
    end

    attr_accessor :idx, :type

  end

  class MzXML < TPPFile
    def initialize fn, fidx=nil
      super(fn,fidx)
    end
  end


  class PepXML  < TPPFile
    def initialize fn, fidx=nil
      super(fn,fidx)
    end

    def get_header
      self.rewind
      l = x = ""
      
      while(self.pos< @idx["1"][:pos] && (!self.eof?) )
        l = self.readline
        x += l
        
      end
      
           
      return x
      
    end

    def filter_peptides fn, peps
      #Here we build the protein_group xml piece to transform
      #it is basically the protein_summary struct with a single protein_group child
      
      #first check if fn is null
      return nil if fn.nil?
      
      #write header to temp file first
      tmpfile = File.open(fn, "w")
      self.rewind
      l = x = ""
      x = self.get_header
      #STDERR.puts("Writing Header:\n")
      tmpfile.write(x)

      #now loop through each entry
      1.upto(@idx.keys.length) do |i|
        #STDERR.puts("Searching #{i}:\n")
        peps.each('+') do |pep|   
          #if x contains p then write and break else continue loop till end 
          #if ! x.index("peptide=\"#{pep.chomp('+')}\"").nil? then
          #  tmpfile.write(x)
          #  STDERR.puts("Found #{pep}")
          #  break
          #end
          #if x contains p then write and break else continue loop till end 
          if @idx[i.to_s][:peptide].eql?(pep.chomp('+')) then
            tmpfile.write(get_sq(i.to_s))
            #STDERR.puts("Found #{pep}")
            break
          end


        end
      end
      
      #write end of file
      tmpfile.write( "\n</msms_run_summary>\n</msms_pipeline_analysis>\n\n")

      
    end

 
    def get_sq num
      self.pos = @idx[num][:pos]
      l = x = ""
      while(!self.eof?)
        l = self.readline
        x += l
        break if (l =~ /\<\/spectrum_query\>/)
      end
      return x
    end

    def get_peptide_count
      peptidecounts
      #need to generate  new index of fraction tags. 
      #for each summary tag
      #loop through each tag segment and count spectrum tags
      #add count to hash
      #return has


    end


    
  end

  class ProtXML < TPPFile
    
    def initialize fn, fidx=nil
      super(fn,fidx)
    end

    def get_pg num
     
      self.pos = @idx[num][:pos]
      l = x = ""
      while(!self.eof?)
        l = self.readline
        x += l
        break if (l =~ /\<\/protein_group\>/)
      end
      return x
    end    
    
    def get_header
      self.rewind
      l = x = ""
      
      while(self.pos< @idx["1"][:pos] && (!self.eof?) )
        l = self.readline
        x += l
        
      end
      
           
      return x
      
    end

    def build_summary
      #get the header and then just add some closing tags. 
      x = self.get_header
        x += "<protein_group_count>#{@idx.keys.length}</protein_group_count>\n\n"

       x += '</protein_summary>'
      return x
      
      
    end


    def build_single_group num, fn=nil
      #Here we build the protein_group xml piece to transform
      #it is basically the protein_summary struct with a single protein_group child
      
      #read header first
      self.rewind
      l = x = ""
      
      x = self.get_header
      
      tmpfile = File.open(fn, "w") unless fn.nil?
      tmpfile.write(x) unless fn.nil?
                  
      #now add the selected protein_group
      self.pos = @idx[num][:pos]
      l = ""
      while(!self.eof?)
        l = self.readline
        
        if fn.nil? then
          x += l
        else
          tmpfile.write(l)
        end
        
        break if (l =~ /\<\/protein_group\>/)
      end
      
      #close the summary tag
      x += '</protein_summary>' 
      tmpfile.write('</protein_summary>') unless fn.nil? 
      tmpfile.close
      if fn.nil? then
        return x
      else
        return fn
      end
      
    end
    
  end
  
end
