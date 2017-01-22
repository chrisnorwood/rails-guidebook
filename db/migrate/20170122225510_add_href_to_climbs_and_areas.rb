class AddHrefToClimbsAndAreas < ActiveRecord::Migration[5.0]
  def change
    add_column :areas, :href, :string
    add_column :climbs, :href, :string
  end
end
