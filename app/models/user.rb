class User < ActiveRecord::Base
  before_save { email.downcase! }
  validates :name, presence: true, length: {maximum:50}
  reg_exp_for_addresses = /\A[\w\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\Z/i  #i в конце регулярки обозначает нечувствительность к регистру
  #здесь используются скобки(), в которых регулярное выражение. Внутри регулярного выражение можно обрабатывать другое регулярное выражение как символ 
  validates :email, presence: true, format: {with: reg_exp_for_addresses}, uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}
  has_secure_password
end
