class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :post_id

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
