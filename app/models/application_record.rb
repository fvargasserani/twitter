class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def original_user
    Tweet.where(retweet_id: nil).where(user_id: user.id).pluck(:id).join(',')
  end

end
