class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.integer :user_id
      t.string :plant_name
      t.date :last_watered_date
      t.integer :watering_frequency
      t.string :sunlight_requirement
      t.string :soil_type
      t.string :other_tips

      t.timestamps
    end
  end
end
