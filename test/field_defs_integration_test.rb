#require field_defs plugin
require File.expand_path(File.dirname(__FILE__) + '/../../field_defs/init')

require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

#include helpers directory in load path
$:.unshift "#{File.dirname(__FILE__)}/mocks/helpers"

require File.join(MOCK_CONTROLLER_DIR, 'def_squirrels_controller')

class FieldDefsIntegrationTest < ActionController::TestCase
  include ActionView::Helpers::FormHelper

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @bob = Squirrel.create(:name => "Bob", :fur_color => "Gray", :weight => 2, :social_security_number => "1234561234")
  end
  
  #test every combination of:
    # 3 fields:  not in field defs, in field defs (default), in field defs (customize)
    
  #with views:
    # 3 views: show, edit, hide
    # 3 views: show customized, edit customized, hide customized (ref default_something)
    # 3 views: show customized, edit customized, hide customized (ref the field)
        #(one of these should raise error)
  
  def test_basics
    @controller = DefSquirrelsController.new
    @squirrel = @bob
    
    get "show", :id => @bob, :view => 'name'    
    assert_equal("<span id='squirrel_name'>me llamo Bob</span>", @response.body)

    get "edit", :id => @bob, :view => 'name'
    assert_equal(text_area(:squirrel, :name), @response.body)
    
    get "hide", :id => @bob, :view => 'name'
    assert_equal("", @response.body)
    
    get "show", :id => @bob, :view => 'fur_color'
    assert_equal("Gray", @response.body)

    get "edit", :id => @bob, :view => 'fur_color'
    assert_equal(text_field(:squirrel, :fur_color, :maxlength => 255, :size => 30), @response.body)

    get "hide", :id => @bob, :view => 'fur_color'
    assert_equal("", @response.body)

    get "show", :id => @bob, :view => 'weight'
    assert_equal("<span id='squirrel_weight'>2</span>", @response.body)

    get "edit", :id => @bob, :view => 'weight'
    assert_equal(text_field(:squirrel, :weight), @response.body)

    get "hide", :id => @bob, :view => 'weight'
    assert_equal("", @response.body)
  end
  
  def test_customized_in_the_view_and_calling_defaults
    @controller = DefSquirrelsController.new
    @squirrel = @bob
    
    get "show", :id => @bob, :view => 'name_custom_default'
    assert_equal("customized " +"me llamo Bob", @response.body)

    get "edit", :id => @bob, :view => 'name_custom_default'
    assert_equal("customized " +text_area(:squirrel, :name), @response.body)
    
    get "hide", :id => @bob, :view => 'name_custom_default'
    assert_equal("customized " +"", @response.body)
    
    get "show", :id => @bob, :view => 'fur_color_custom_default'
    assert_equal("customized " +"Gray", @response.body)

    get "edit", :id => @bob, :view => 'fur_color_custom_default'
    assert_equal("customized " +text_field(:squirrel, :fur_color), @response.body)

    get "hide", :id => @bob, :view => 'fur_color_custom_default'
    assert_equal("customized " +"", @response.body)

    get "show", :id => @bob, :view => 'weight_custom_default'
    assert_equal("customized " +"2", @response.body)

    get "edit", :id => @bob, :view => 'weight_custom_default'
    assert_equal("customized " +text_field(:squirrel, :weight), @response.body)

    get "hide", :id => @bob, :view => 'weight_custom_default'
    assert_equal("customized " +"", @response.body)    
  end

  def test_customized_in_the_view_and_calling_defaults
    @controller = DefSquirrelsController.new
    @squirrel = @bob
    
    get "show", :id => @bob, :view => 'name_custom_custom'
    assert_equal("Show name Foo! me llamo Bob", @response.body)

    get "edit", :id => @bob, :view => 'name_custom_custom'
    assert_equal("Edit name Foo! " +text_area(:squirrel, :name), @response.body)
    
    get "hide", :id => @bob, :view => 'name_custom_custom'
    assert_equal("Hide name Foo! ", @response.body)
    
    # get "show", :id => @bob, :view => 'fur_color_custom_custom'
    # assert_equal("customized " +"Gray", @response.body)
    # 
    # get "edit", :id => @bob, :view => 'fur_color_custom_custom'
    # assert_equal("customized " +text_field(:squirrel, :fur_color), @response.body)
    # 
    # get "hide", :id => @bob, :view => 'fur_color_custom_custom'
    # assert_equal("customized " +"", @response.body)
    # 
    # get "show", :id => @bob, :view => 'weight_custom_custom'
    # assert_equal("customized " +"2", @response.body)
    # 
    # get "edit", :id => @bob, :view => 'weight_custom_custom'
    # assert_equal("customized " +text_field(:squirrel, :weight), @response.body)
    # 
    # get "hide", :id => @bob, :view => 'weight_custom_custom'
    # assert_equal("customized " +"", @response.body)
  end
  
  # def test_show_from_fields
  #   @controller = DefSquirrelsController.new
  #   get "show", :id => @bob, :view => 'basic_test'
  #   
  #   assert_equal("Gray me llamo Bob", @response.body)
  # end
  # 
  # def test_edit_from_fields
  #   @controller = DefSquirrelsController.new
  #   get "edit", :id => @bob, :view => 'basic_test'
  #   
  #   puts @response.body
  #   # assert_equal("Gray me llamo Bob", puts @response.body)
  # end
  
  # def test_with_field_defs
  #   @controller = DefSquirrelsController.new
  #   get "show", :id => @bob, :view => 'name'
  #   
  #   puts @response.body
  # 
  #   get "edit", :id => @bob, :view => 'name'
  #   
  #   puts @response.body
  # end
  

end