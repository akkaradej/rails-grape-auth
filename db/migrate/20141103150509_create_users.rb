class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :type
      t.boolean :banned, default: false

      t.timestamps
    end
  end
end
