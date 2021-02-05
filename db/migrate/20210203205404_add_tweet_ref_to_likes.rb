class AddTweetRefToLikes < ActiveRecord::Migration[6.0]
  def change
    add_reference :likes, :tweet, null: false, foreign_key: true
  end
end
