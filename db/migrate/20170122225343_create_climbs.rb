class CreateClimbs < ActiveRecord::Migration[5.0]
  def change
    create_table :climbs do |t|
      t.string :name
      t.string :grade
      t.string :type
      t.string :fa
      t.text :description
      t.text :location
      t.text :protection
      t.integer :area_id

      t.timestamps
    end
  end
end
