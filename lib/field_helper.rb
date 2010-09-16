# When this plugin is installed, this module is automatically included as a helper for all views
#
# The only method you should call directly is field
#
# The other public methods (edit_and_show_as, edit_as, show_as, hide_as) should only be called within the context of an open field block
#
# You can override determine_field_show_edit_or_deny by defining it on your controller 
module FieldHelper
  
  attr_accessor :view_controls
  
  # See README for full explanation
  #
  # field must always be called with a block (even if it's empty), because the block is needed to obtain a binding to get access to the erb buffer variable
  # 
  # The RIGHT way:
  #     <% field(:name){} %>
  # 
  # The WRONG way:
  #     <%= field(:name) %>
  #
  # Typically your block will not need any arguments, but it is always called with a single argument, 
  # which is a ViewControlledField instance used for disambiguation in the case that you are embeding field calls inside other field calls.
  # By using the ViewControlledField yielded to your block to define your edit_as, show_as, etc.. you avoid ambiguity with other open field blocks
  def field(field_name, &proc)  # :yields: ViewControlledField
    #to output stuff you need a proc (so you can get it's binding like form_for does)
    # concat("this is field " + field_name.to_s", proc.binding)
    
    #create an object to capture the edit_as and show_as blocks
    view_control = ViewControlledField.for_field(field_name, proc.binding, self)
    @view_control = view_control
    #capture anything that's directly inside the field block
    content_for_field = view_control.capture
        
    show_edit_or_deny_proc = Proc.new do |controller, action, field_name|
      if controller.respond_to?(:determine_field_show_edit_or_deny)
        controller.send(:determine_field_show_edit_or_deny, action, field_name)
      else
        determine_field_show_edit_or_deny(action, field_name)
      end
    end
    
    
    behavior = show_edit_or_deny_proc.call(self.controller, current_action, view_control.name)
    
    # RAILS_DEFAULT_LOGGER.debug("behavior for: #{view_control.name} is #{behavior}")
    
    if(behavior == :edit)
      #if we are in edit_as flow, render the edit_as block
      #if there is no edit_as block, render the default for a edit_as (look at how scaffolding does it)
      # eval "@content_for_edit_as_field_#{field_name} = get_edit_view(view_control)"
      
      # RAILS_DEFAULT_LOGGER.debug("rendering edit proc for #{view_control.name}")
      
      content_for_field += get_edit_view(view_control)      
    elsif(behavior == :show)
      #if we are in show_as flow, render the show_as block
      #if there is no show_as block, render the default for a show_as (look at how scaffolding does it)
      # eval "@content_for_show_as_field_#{field_name} = get_show_view(view_control)"

      # RAILS_DEFAULT_LOGGER.debug("rendering show proc for #{view_control.name}")

      content_for_field += get_show_view(view_control)      
    else
      
      # RAILS_DEFAULT_LOGGER.debug("rendering nothing for #{view_control.name}")
      
      #no output (hide)
      content_for_field += get_hide_view(view_control)
    end
    concat(content_for_field)
  end
  
  #Shortcut for defining edit_as and show_as with the same contents
  def edit_and_show_as(arg = nil, &proc) # :yields: field_def or nil
    edit_as(arg, &proc)
    show_as(arg, &proc)
  end
  
  # Define the logic to be used when editing this field
  #
  # You can do this as an argument, or to avoid un-needed executions and/or mix in straight HTML, call with a block
  def edit_as(arg = nil, &proc) # :yields: field_def or nil
    @view_control.edit_as(arg, &proc)
  end

  # Define the logic to be used when showing this field
  #
  # You can do this as an argument, or to avoid un-needed executions and/or mix in straight HTML, call with a block
  def show_as(*args, &proc) # :yields: field_def or nil
    @view_control.show_as(*args, &proc)
  end
  
  # Define the logic to be used when hiding this field
  #
  # You can do this as an argument, or to avoid un-needed executions and/or mix in straight HTML, call with a block
  def hide_as(arg = nil, &proc) # :yields: field_def or nil
    @view_control.hide_as(arg, &proc)
  end
  
  protected
  
  # Default implementation for determining the view mode for a given action and field
  # 
  # Override this method in your controller to define specific logic for determining which view mode you are in
  #
  # Copying this implementation's source verbatim is a good starting point
  #
  # Should return :edit if the current action and field should use edit view mode.  
  # :show for the show view mode, 
  # and :hide or nil or anything else for the hide view mode
  #
  # example:  DefinePermissions plugin defines ProtectFields 
  # which when included in your controller overrides this method to make calls to the permission checks in that plugin
  def determine_field_show_edit_or_deny(action, field_name)
    if([:new, :edit, :create, :update].include? action)
      :edit
    elsif([:show, :delete].include? action)
      :show
    else
      :hide
    end
  end
  
  # determine the current action, needed for the call to determine_field_show_edit_or_deny
  def current_action
    self.controller.action_name.to_sym
  end
  
  # Needed for the implementation of default view modes
  #
  # Calls current_model on the controller... which must implement current_model in order for this plugin to work
  # 
  # Example: <tt>UsersController.current_model</tt> should return the <tt>User</tt> class
  #
  # make_resourceful provides this method by default
  def current_model
    unless self.controller.respond_to? :current_model
      raise ArgumentError, "#{self.controller} expected to define current_model.  Example: UsersController.current_model should return the User class"
    end
    self.controller.send(:current_model)
  end
  
  # Needed for the implementation of default view modes
  #
  # Calls current_object on the controller... which must implement current_object in order for this plugin to work
  # 
  # Example: <tt>UsersController.current_object</tt> would return <tt>@user</tt>
  #
  # make_resourceful provides this method by default
  def current_object
    unless self.controller.respond_to? :current_object
      raise ArgumentError, "#{self.controller} expected to define current_object.  Example: UsersController.current_object should return a @user"
    end
    self.controller.send(:current_object)
  end
  
  # This is what gets called when you don't provide an override for a field with edit_as
  #
  # It can also be useful to call this method directly from within your definition of edit_as to effectively 'wrap' the default implementations
  #
  # Example:
  #
  #   edit_as{ %>
  #      <p><b>Name</b><br/>
  #      <%=default_edit%></p> 
  #   <% }
  #
  def default_edit(for_view_control = @view_control)
    if this_field = get_field_defs_field(for_view_control)
      this_field.edit_proc.call(self, current_object)
    else
      html_options = {}
      if current_model.columns_hash.has_key?(for_view_control.name)
        db_column = current_model.columns_hash[for_view_control.name]
        
        if !db_column.limit.blank?
          limit_attrib = db_column.type == :decimal ? db_column.limit + 1 : db_column.limit
          html_options.merge!(:maxlength => limit_attrib, :size => 30)
        end
        
        html_options.merge!(:class => db_column.type.to_s)
      end
      text_field(current_model.to_s.underscore, for_view_control.name, html_options)
      # current_object.send(for_view_control.name).to_s
    end
  end
  
  # This is what gets called to retrieve the appropriate text to display for the edit view of a field
  def get_edit_view(view_control) # :nodoc:
    if(view_control.edit_as_proc.nil?)
      default_edit(view_control)
      # text_field(current_model.to_s.underscore, view_control.name)
    else
      capture(get_field_defs_field(view_control), &view_control.edit_as_proc)
    end
  end
  
  # This is what gets called when you don't provide an override for a field with show_as
  #
  # It can also be useful to call this method directly from within your definition of edit_as to effectively 'wrap' the default implementations
  #
  # Example:
  #
  #   show_as{ %>
  #      <p><b>Name</b><br/>
  #      <%=default_show%></p> 
  #   <% }
  #
  def default_show(for_view_control = @view_control)
    if this_field = get_field_defs_field(for_view_control)
      this_field.display_proc.call(this_field.reader_proc.call(current_object))
    else
      current_object.send(for_view_control.name).to_s
    end
  end

  # This is what gets called to retrieve the appropriate text to display for the show view of a field
  def get_show_view(view_control) # :nodoc:
    to_return = nil
    if(view_control.show_as_proc.nil?)
      to_return = default_show(view_control)
    else
      to_return = capture(get_field_defs_field(view_control), &view_control.show_as_proc)
    end
    if wrap_proc = view_control.show_wrap_proc
      to_return = wrap_proc.call(current_model.to_s.underscore, view_control.name, to_return)
    end
    to_return
  end
  
  # This is what gets called when you don't provide an override for a field with hide_as
  def default_hide(for_view_control = @view_control)
    if this_field = get_field_defs_field(for_view_control)
      this_field.hide_proc.call(current_object)
    else
      ""
    end
  end

  # This is what gets called to retrieve the appropriate text to display for the hide view of a field
  def get_hide_view(view_control) # :nodoc:
    if(view_control.hide_as_proc.nil?)
      default_hide(view_control)
    else
      capture(get_field_defs_field(view_control), &view_control.hide_as_proc)
    end
  end
  
  private
  
  #retrieve the FieldDefs object assuming it's available in the current context, otherwise get nil
  def get_field_defs_field(view_control)
    if (self.respond_to? :field_defs) && this_field = field_defs.field_called(view_control.name)
      this_field
    end
  end
    
end

#Inner class used to keep track of calls to field and in-context calls to edit_as, show_as etc... Generally you shouldn't have to deal with this class.
class ViewControlledField
  attr_accessor :name, :edit_as_proc, :show_as_proc, :hide_as_proc, :proc_binding, :this_page, :outer_content, :show_wrap_proc
  
  #initializer used by FieldHelper.field
  def self.for_field(field_name, erbout_proc_biding, this_page) # :nodoc:
    this_page.view_controls ||= {}
    this_page.view_controls[field_name.to_sym] = ViewControlledField.new(field_name, this_page)
    this_page.view_controls[field_name.to_sym].proc_binding = erbout_proc_biding
    return this_page.view_controls[field_name.to_sym]
  end
  
  #initialize with a field_name and a reference to whatever 'self' evaluates to in the view
  def initialize(field_name, this_page) # :nodoc:
    self.name = field_name
    self.this_page = this_page
    self.show_wrap_proc = (@@default_show_proc ||= Proc.new do |curr_model_name, curr_field_name, v|
      "<span id='#{curr_model_name}_#{curr_field_name}'>#{v}</span>"
    end)
  end
  
  #calls the ActionView capture method from the 'self' view
  def capture # :nodoc:
    self.outer_content ||= this_page.capture(self, &proc_binding)
    self.outer_content.to_s
  end
  
  #Shortcut for defining edit_as and show_as with the same contents
  def edit_and_show_as(arg = nil, &proc)
    edit_as(arg, &proc)
    show_as(arg, &proc)
  end  
  
  # Define the logic to be used when editing this field
  #
  # You can do this as an argument, or to avoid un-needed executions and/or mix in straight HTML, call with a block
  def edit_as(arg = nil, &proc)
    # RAILS_DEFAULT_LOGGER.debug('set edit_as proc to ' + proc.inspect)
    if block_given?
      self.edit_as_proc = proc
    else
      self.edit_as_proc = Proc.new do
        arg.to_s
      end      
    end
  end
  
  # Define the logic to be used when showing this field
  #
  # You can do this as an argument, or to avoid un-needed executions and/or mix in straight HTML, call with a block
  def show_as(*args, &proc)
    # RAILS_DEFAULT_LOGGER.debug('set show_as proc to ' + proc.inspect)
    opts = (args.last.is_a?(Hash) && args.pop) || {}
    if opts[:show_wrap_proc]
      if opts[:show_wrap_proc].is_a?(Proc)
        self.show_wrap_proc = opts[:show_wrap_proc]
      end
    else
      self.show_wrap_proc = nil
    end
    if block_given?
      self.show_as_proc = proc
    else
      if args.first
        self.show_as_proc = Proc.new do
          args.first.to_s
        end
      end
    end
  end
  
  # Define the logic to be used when hiding this field
  #
  # You can do this as an argument, or to avoid un-needed executions and/or mix in straight HTML, call with a block
  def hide_as(arg = nil, &proc)
    if block_given?
      self.hide_as_proc = proc
    else
      self.hide_as_proc = Proc.new do
        arg.to_s
      end
    end
  end  
    
end