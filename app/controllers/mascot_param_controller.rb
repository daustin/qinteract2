class MascotParamController < ApplicationController
  def index
 
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
 

   def view

    @parfile =  MascotParam.find(params[:id])
    @contents = @parfile.exportToFile()

    # @parfile.importVars(@contents2)
  
    render :layout => false



  end

  def new


     h =  params[:mascot_param]

    if h.nil?
      @mascot_param = MascotParam.new
    else
      @mascot_param =  MascotParam.find(h['id'])
      @mascot_param.filename = ''
    end
      
    @mascot_params = MascotParam.find(:all)

    @taxonomy = MascotParam.getTAXONOMY
    @databases = MascotParam.getDB
    @enzymes = MascotParam.getCLE
    @instruments = MascotParam.getINSTRUMENT
    @mods = MascotParam.getMODS
    @mods  = @mods + MascotParam.getHIDDEN_MODS

    render :layout => false
  end

  def create
    @mascot_param = MascotParam.new(params[:mascot_param])
    if ! @mascot_param.save
      flash[:notice] = 'MascotParam was not successfully created.'
      @taxonomy = MascotParam.getTAXONOMY
      @databases = MascotParam.getDB
      @enzymes = MascotParam.getCLE
      @instruments = MascotParam.getINSTRUMENT
      @mods = MascotParam.getMODS
      @mods  = @mods + MascotParam.getHIDDEN_MODS
      
      redirect_to :action => 'new', :layout => false
      return
    end
  end

  def edit
    @mascot_param = MascotParam.find(params[:id])
      @taxonomy = MascotParam.getTAXONOMY
      @databases = MascotParam.getDB
      @enzymes = MascotParam.getCLE
      @instruments = MascotParam.getINSTRUMENT
      @mods = MascotParam.getMODS
      @mods  = @mods + MascotParam.getHIDDEN_MODS
      render :layout => false
  end
  
  def update
    @mascot_param = MascotParam.find(params[:id])
    if ! @mascot_param.update_attributes(params[:mascot_param])
      flash[:notice] = 'MascotParam was not successfully updated.'
      render :action => "edit", :layout => false, :id => params[:id]
      return
    end
    render :action => "create", :layout => false
    return
    
  end
  
  

end
