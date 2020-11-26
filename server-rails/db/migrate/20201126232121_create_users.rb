class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :vonage_id, unique: true
      t.string :name, null: false, unique: true
      t.string :display_name
      t.string :password_digest
      t.boolean :is_active, default: true
      t.datetime :sync_at

      t.timestamps
    end
  end
end
