class RenameTypeColOnClimbs < ActiveRecord::Migration[5.0]
  def change
    rename_column :climbs, :type, :style
  end
end
