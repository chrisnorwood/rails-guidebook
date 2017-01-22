class CreateAreas < ActiveRecord::Migration[5.0]
  def change
    create_table :areas do |t|
      t.string :name
      t.string :coord
      t.text :description
      t.text :get_there
      t.integer :parent_id

      t.timestamps
    end
  end
end
