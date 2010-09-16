class SquirrelsController < ActionController::Base

  def rescue_action(e) 
    raise e 
  end
  
  def show
    current_object
    render :action => params[:view]
  end

  def edit
    current_object
    render :action => params[:view]
  end
  
  protected
  
  def current_object
    @squirrel ||= Squirrel.find(params[:id])
  end
  
  def current_model
    Squirrel
  end
  
end