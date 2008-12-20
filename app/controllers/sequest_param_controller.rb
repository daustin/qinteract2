class SequestParamController < ApplicationController

  def index
  end

  def view

    @parfile =  SequestParam.find(params[:id])
    @contents = @parfile.exportToFile()

    # @parfile.importVars(@contents2)
  
    render :layout => false



  end

  def edit
     # old code
     # @contents2 = SequestParam.getContents(params[:id])
     # @sequest_param = SequestParam.new({:filename => "#{params[:id].sub(/\.params/, '')}"})
     # @sequest_param.importVars(@contents2)
     @sequest_param =  SequestParam.find(params[:id])
     @protdb = ProteinDb.getSequestDBFilenames
     render :layout => false



  end

  def new

    h =  params[:sequest_param]

    if h.nil?
      @sequest_param = SequestParam.new
    else
      @sequest_param =  SequestParam.find(h['id'])
      @sequest_param.filename = ''
    end
      
    @sequest_params = SequestParam.find(:all)
    # @sequest_param = SequestParam.new
    @protdb = ProteinDb.getSequestDBFilenames

    render :layout => false

  end

  def create
    @sequest_param = SequestParam.new(params[:sequest_param])
    
   #  if @sequest_param.filename.nil? || @sequest_param.filename.eql?('') || ! @sequest_param.filename.match(' ').nil? then
    #   flash[:notice] = 'FILENAME Is Required and cannot have any spaces. Please fix this and recheck all your fields as they may have been reset.'
     #  @protdb = ProteinDb.getSequestDBFilenames
      # render :action => "new", :layout => false
     # return
    # end

    # puts @sequest_param.exportToFile()
    # fh = File.open("/tmp/qInteract/#{@sequest_param.filename}.params", "w")
    # fh.write(@sequest_param.exportToFile())
    # fh.close
    #save it to temp
    #check if it already exists on server
    # ps = IO.popen("#{SEQUEST_SSH_PREFIX} ls -1 #{SEQUEST_PARAM}/#{@sequest_param.filename}.params")
    # ln = ps.read

    # if ! ln.nil? && ! ln.match("#{@sequest_param.filename}.params").nil? then
      #already exists
      # @exists = true
     
    # end
    # @tempfile = "/tmp/qInteract/#{@sequest_param.filename}.params"
    # render :layout => false
    if ! @sequest_param.save then
       @protdb = ProteinDb.getSequestDBFilenames
      render :action => "new", :layout => false
      return
      
    end
    
  end

  
  def update
    @sequest_param =  SequestParam.find(params[:id])
    if ! @sequest_param.update_attributes(params[:sequest_param]) then
       @protdb = ProteinDb.getSequestDBFilenames
      render :action => "edit", :layout => false, :id => params[:id]
      return

    end
    
    render :action => "create", :layout => false
    return
  end
  

  


end
