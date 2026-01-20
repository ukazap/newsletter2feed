class IncreasePublicIdSizeForUuid < ActiveRecord::Migration[8.1]
  def change
    change_column :feeds, :public_id, :string, limit: 36, null: false
    change_column :feed_entries, :public_id, :string, limit: 36, null: false
  end
end
