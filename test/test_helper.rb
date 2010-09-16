require 'rubygems'
require 'test/unit/notification'
require 'test/unit'

#require 'active_support'
#require 'action_pack/actioncontroller'

require 'activerecord'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'

unless defined?(RAILS_ROOT)
 RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.join(File.dirname(__FILE__), "mocks"))
end

#require this plugin
require File.join(File.dirname(__FILE__), "..", "init")

MOCK_CONTROLLER_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'mocks/controllers')
MOCK_VIEWS_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'mocks/views')
require File.join(MOCK_CONTROLLER_DIR, 'squirrels_controller')
require File.join(MOCK_CONTROLLER_DIR, 'safe_squirrels_controller')

ActionController::Base.view_paths = [MOCK_VIEWS_DIR]
ActionController::Routing::Routes.clear!
ActionController::Routing.controller_paths= [ MOCK_CONTROLLER_DIR ]
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
# ActionView::Base.class_based_error_markings = true

#load the database schema for this test
load File.expand_path(File.dirname(__FILE__) + "/mocks/schema.rb")

#require the mock models for the voting system
require File.expand_path(File.dirname(__FILE__) + '/mocks/models.rb')
