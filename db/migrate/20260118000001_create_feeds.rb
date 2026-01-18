class CreateFeeds < ActiveRecord::Migration[8.1]
  def change
    create_table :feeds do |t|
      t.string :public_id, null: false, limit: 20
      t.string :title, null: false
      t.string :icon
      t.string :email_icon

      t.timestamps
    end

    add_index :feeds, :public_id, unique: true
  end
end
