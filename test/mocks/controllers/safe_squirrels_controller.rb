class SafeSquirrelsController < ActionController::Base

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
  
  def determine_field_show_edit_or_deny(action, field_name)
    #Safe squirrels don't give out their social security number
    if(field_name.to_s == "social_security_number")
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