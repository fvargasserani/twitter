class AddRetweetIdToTweet < ActiveRecord::Migration[6.0]
  def change
    add_column :tweets, :retweet_id, :integer, :default => nil
  end
end
