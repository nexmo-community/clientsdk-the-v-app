class CreateConversations < ActiveRecord::Migration[6.0]
  def change
    create_table :conversations do |t|
      t.string :vonage_id, unique: true
      t.string :name, null: false
      t.string :display_name
      t.string :state, null: false
      t.datetime :vonage_created_at

      t.timestamps
    end
  end
end
