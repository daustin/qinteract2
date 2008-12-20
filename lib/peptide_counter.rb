require 'tppfile'
require 'time'

#this file takes an xml input file and a +-delim list of peptides to filter on.
# it indexes the xml file, then builds the peptides based on the pep list

JAVA_BIN = "java"
SAX_JAR = "/home/daustin/saxon.jar"
SAX_CMD = "#{JAVA_BIN} -Xms1536m -Xmx1536m -jar #{SAX_JAR}"

# do the same for protxml:
#puts "doing for ProtXML now"
#f = TPP::PepXML.new(ARGV[0])
#puts Time.now
logfile = File.open("indexer.log", "w")
logfile.write("Start time: ")
logfile.write(Time.now.to_s)
logfile.write("\n")
#puts "get a random search_query"
#id = f.idx.keys[rand(f.idx.keys.length) ]

#puts "dumping indx"
#puts Time.now
# dump the index to a file so we can quickly load it
#f.dump_index(File.basename(ARGV[0]) + ".idx")
#puts Time.now

# open the file again and read the same scan
#puts "reopen file with idx and gets the search again and compare it to last one"
#puts Time.now
f = TPP::PepXML.new(ARGV[0]) if  ! File.exist?(ARGV[0]+ ".idx")

f = TPP::PepXML.new(ARGV[0], ARGV[0]+ ".idx")
#puts Time.now

f.parsedump_run_summary_index(ARGV[0]+".sidx")

@idx = YAML::load(File.open(ARGV[0]+".sidx"))
puts @idx
logfile.write("Finished time: ")
logfile.write(Time.now.to_s)
logfile.write("\n")
