class AddGameToPerformances < ActiveRecord::Migration
  def self.up
    add_column :performances, :game, :string
  end

  def self.down
    remove_column :performances, :game
  end
end
