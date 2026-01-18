class CreateFeedEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_entries do |t|
      t.string :public_id, null: false, limit: 20
      t.references :feed, null: false, foreign_key: true
      t.string :author
      t.string :title, null: false
      t.text :content

      t.timestamps
    end

    add_index :feed_entries, :public_id, unique: true
    add_index :feed_entries, [ :feed_id, :created_at ]
  end
end
