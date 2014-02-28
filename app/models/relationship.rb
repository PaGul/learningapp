class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User" #обращение с помощью ключа follower_id к таблице follower, которая на самом деле таблица User
  belongs_to :followed, class_name: "User"
  validates :followed_id, presence: true
  validates :follower_id, presence: true
end