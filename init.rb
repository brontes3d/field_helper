$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'field_helper'

ActionController::Base.helper FieldHelper

if defined?(FieldDefs)
  FieldDefs.global_defaults do
      default_for_proc_type(:edit_proc) do |field_defs|
        Proc.new do |view, thing|
          to_return = nil
          thing_responds_to_columns_hash = thing.class.respond_to?(:columns_hash)
          klass = thing.class
          
          if thing_responds_to_columns_hash
            field_name = field_defs.field_name.to_s
            if column = klass.columns_hash[field_name]
              case column.type
              when :boolean
                to_return = view.check_box(field_defs.for_model.name.to_s.underscore, field_defs.field_name)
              when :string
                html_options = {:maxlength => klass.columns_hash[field_name].limit, :size => 30} if !column.limit.blank?
                to_return = view.text_field(klass.to_s.underscore, field_name, html_options || {})
              end
            end
          end
          
          to_return ||= view.text_field(field_defs.for_model.name.to_s.underscore, field_defs.field_name)
        end
      end
      default_for_proc_type(:hide_proc) do |field_defs|
        Proc.new do |thing|
          ""
        end
      end
  end
end