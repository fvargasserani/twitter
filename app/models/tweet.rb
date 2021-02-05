class Tweet < ApplicationRecord
  belongs_to :user
  belongs_to :source_tweet, optional: true, inverse_of: :retweets, class_name: 'Tweet', foreign_key: 'retweet_id'
  has_many :retweets, inverse_of: :source_tweet, class_name: 'Tweet', foreign_key: 'retweet_id', dependent: :destroy
  has_many :likes, dependent: :destroy
  validates_length_of :content, :within => 1..140, :too_long => "can't be over 140 characters", :too_short => "can't be blank"
  validates :retweet_id, uniqueness: { scope: :user_id }
  
  def content
    if source_tweet
      source_tweet.content
    else
      super
    end
  end
  
  def retweet_count
    Tweet.where.not(retweet_id: nil).where(retweet_id: self.id).count
  end

  def retweeted?(user)
    !!self.retweets.find{|tweet| tweet.user_id == user.id}
  end

  def like_count
    Like.where(tweet_id: id).pluck(:tweet_id).count
  end

  def liked?(user)
    !!self.likes.find{|like| like.user_id == user.id}
  end
  
end