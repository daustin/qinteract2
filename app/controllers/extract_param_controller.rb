class ExtractParamController < ApplicationController
  def index
  
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
   
  end


   def view

    @parfile =  ExtractParam.find(params[:id])
    @contents = @parfile.exportToFile()

    # @parfile.importVars(@contents2)
  
    render :layout => false



  end


  def new

    h =  params[:extract_param]

    if h.nil?
      @extract_param = ExtractParam.new
    else
      @extract_param =  ExtractParam.find(h['id'])
      @extract_param.filename = ''
    end
      
    @extract_params = ExtractParam.find(:all)
    # @extract_param = ExtractParam.new
  

      
  end

  def create
    @extract_param = ExtractParam.new(params[:extract_param])
    if ! @extract_param.save
      flash[:notice] = 'ExtractParam was not successfully created.'
      redirect_to :action => 'new', :layout => false

    end
  end

  def edit
    @extract_param = ExtractParam.find(params[:id])
   
  end

  def update
    @extract_param = ExtractParam.find(params[:id])
    if ! @extract_param.update_attributes(params[:extract_param])
      flash[:notice] = 'ExtractParam was not successfully updated.'
      redirect_to :action => 'edit', :id => @extract_param
    end
     
    render :action => "create", :layout => false
      return
 
  end

end
