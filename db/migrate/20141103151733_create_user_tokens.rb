class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.references :user, index: true
      t.string :token, unique: true

      t.timestamps
    end
  end
end
