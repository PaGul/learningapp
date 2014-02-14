class User < ActiveRecord::Base
  before_save { self.email=email.downcase }
  before_create :create_remember_token #вместо блока осуществляется поиск метода по имени
  validates :name, presence: true, length: {maximum:50}
  reg_exp_for_addresses = /\A[\w\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\Z/i  #i в конце регулярки обозначает нечувствительность к регистру
  #здесь используются скобки(), в которых регулярное выражение. Внутри регулярного выражение можно обрабатывать другое регулярное выражение как символ 
  validates :email, presence: true, format: {with: reg_exp_for_addresses}, uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}
  has_secure_password
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end
  
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s) #to_s необязателен, нужен на всякий случай
  end
  
  
  private
  
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
  
end
