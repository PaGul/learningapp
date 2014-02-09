class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: {maximum:50}
  reg_exp_for_addresses = /\A[\w+\-+.]+@[a-z\d\-.]+\.[a-z]+\Z/i
  validates :email, presence: true, format: {with: reg_exp_for_addresses}, uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}
  has_secure_password
end
