class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def users_who_liked
    Like.joins(:user).where(user_id: user.id).pluck(:picture).join(' ,')
  end
end
