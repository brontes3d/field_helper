module DefHelper
  
  def self.field_defs
    @@field_definitions ||= FieldDefs.new(Squirrel) do
      
      default_for_proc_type(:foo_proc) do |field_defs|
        Proc.new do
          "#{field_defs.field_name} Foo!"
        end
      end
      
      field(:fur_color)
      field(:name).human_name('Name').display_proc do |name|
        "me llamo #{name}"
      end.edit_proc do |view, squirrel|
        view.text_area('squirrel', :name)
      end
      
    end
  end
  
  def field_defs
    DefHelper.field_defs
  end
  
end