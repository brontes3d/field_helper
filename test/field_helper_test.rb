require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')


class FieldHelperTest < ActionController::TestCase
  include ActionView::Helpers::FormHelper

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @bob = Squirrel.create(:name => "Bob", :fur_color => "Gray", :weight => 2, :social_security_number => "1234561234")
  end
  
  def test_show_default
    @controller = SquirrelsController.new
    get "show", :id => @bob, :view => 'name'
    
    assert_equal("<span id='squirrel_name'>Bob</span>", @response.body)
  end
  
  def test_edit_default
    @controller = SquirrelsController.new
    get "edit", :id => @bob, :view => 'name'
        
    @squirrel = @bob
    assert_equal(text_field(:squirrel, :name), @response.body)
  end
  
  #Test the various modes of specifying show_as and edit_as
  def test_show_as_edit_as_specified_as_a_block
    @controller = SquirrelsController.new
    
    get "show", :id => @bob, :view => 'name_as_a_block'    
    assert_equal("showing name", @response.body)

    get "edit", :id => @bob, :view => 'name_as_a_block'
    assert_equal("editing name", @response.body)
  end

  def test_show_as_edit_as_specified_as_a_param
    @controller = SquirrelsController.new
    
    get "show", :id => @bob, :view => 'name_as_a_param'    
    assert_equal("showing name", @response.body)

    get "edit", :id => @bob, :view => 'name_as_a_param'
    assert_equal("editing name", @response.body)
  end

  def test_multiple_outputs_of_the_same_field
    @controller = SquirrelsController.new
    
    get "show", :id => @bob, :view => 'name_output_twice'
    assert_equal("showing name onceshowing name twice", @response.body)

    get "edit", :id => @bob, :view => 'name_output_twice'
    assert_equal("editing name onceediting name twice", @response.body)
  end
  
  def test_fields_within_fields
    @controller = SquirrelsController.new
    
    get "show", :id => @bob, :view => 'fields_within_fields'
    assert_equal("<span id='squirrel_name'>Bob</span> 2 lbs.", @response.body)

    get "edit", :id => @bob, :view => 'fields_within_fields'
    @squirrel = @bob
    assert_equal(text_field(:squirrel, :name)+"(edit fur field)", @response.body)
  end
  
  def test_edit_and_show_as
    @controller = SquirrelsController.new
    
    get "show", :id => @bob, :view => 'edit_and_show_as'
    assert_equal("namename", @response.body)

    get "edit", :id => @bob, :view => 'edit_and_show_as'
    assert_equal("namename", @response.body)
  end
  
  #test with determine_field_show_edit_or_deny defined on the controller (SafeSquirrelsController)
  def test_safe_squirrels
    @controller = SafeSquirrelsController.new
    
    get "show", :id => @bob, :view => 'stuff'
    assert_equal("<span id='squirrel_name'>Bob</span>", @response.body)
  end
  
  def test_hide_as
    @controller = SafeSquirrelsController.new
    
    get "show", :id => @bob, :view => 'hide_as_test'
    assert_equal("not telling you", @response.body)
  end

end
