class CreatePerformances < ActiveRecord::Migration
  def self.up
    create_table :performances do |t|
      t.string :name
      t.string :position
      t.string :time
      t.string :fg
      t.string :tg
      t.string :ft
      t.string :diff
      t.integer :orb
      t.integer :rb
      t.integer :ass
      t.integer :to
      t.integer :stl
      t.integer :bs
      t.integer :ba
      t.integer :pf
      t.integer :pts
      t.timestamps
    end
  end

  def self.down
    drop_table :performances
  end
end
