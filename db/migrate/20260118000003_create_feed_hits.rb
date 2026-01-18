class CreateFeedHits < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_hits do |t|
      t.references :feed, null: false, foreign_key: true
      t.datetime :created_at, null: false
    end

    add_index :feed_hits, [ :feed_id, :created_at ]
  end
end
