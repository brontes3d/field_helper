ActiveRecord::Schema.define do

  create_table "squirrels", :force => true do |t|
    t.string   "name"
    t.string   "fur_color"
    t.integer  "weight"
    t.datetime "birthday"
    t.string   "social_security_number"
  end

end