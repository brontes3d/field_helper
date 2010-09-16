class DefSquirrelsController < ActionController::Base
  helper :def
  
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

  def hide
    current_object
    render :action => params[:view]
  end
  
  protected
  
  def determine_field_show_edit_or_deny(action, field_name)
    if(action.to_s == "hide")
      return :hide
    end
    if(action.to_s == "edit")
      return :edit
    else
      return :show
    end    
  end
  
  def current_object
    @squirrel ||= Squirrel.find(params[:id])
  end
  
  def current_model
    Squirrel
  end
  
end