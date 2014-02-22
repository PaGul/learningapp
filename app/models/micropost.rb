class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('created_at DESC') } #SQL для “по убыванию”, т.е., в порядке убывания от новых к старым.
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
