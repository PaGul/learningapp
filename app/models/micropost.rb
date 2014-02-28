class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('created_at DESC') } #SQL для “по убыванию”, т.е., в порядке убывания от новых к старым. используется лямбда-выражение
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  
  def self.from_users_followed_by(user) #используется SQL-подзапрос
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user)
  end
  
  # без использования подзапросов
  # def self.from_users_followed_by(user)
  #   followed_user_ids = user.followed_user_ids
  #   where("user_id IN (?) OR user_id = ?", followed_user_ids, user)
  # end
end
