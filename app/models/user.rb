class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy # dependent удаляет посты в случае удаления пользователя
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed # пользователь передаёт таблице relationships свой id и передаёт его follower_id. Все элементы с заданным follower_id образуют ассоциацию relationship. Вторая команда преобразует все найденные соответствующие followed_id в массив followed_users с пользователями, у которых id=followed_id
  has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy # происходит обращение к модели relationship, но по ключу followed_id. Создаётся has many-ассоциация под названием reverse_relationship, поиск во всё той же таблице Relationship
  has_many :followers, through: :reverse_relationships, source: :follower # необязательно было писать source: :follower
  before_save { self.email=email.downcase }
  before_create :create_remember_token #вместо блока осуществляется поиск метода по имени
  validates :name, presence: true, length: { maximum:50 }
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
  
  def feed
    Micropost.from_users_followed_by(self)
    #Micropost.where("user_id = ?", id) # знак вопроса гарантирует, что id корректно маскирован прежде чем быть включенным в лежащий в его основе SQL запрос. То что в кавычках - шаблон для отправки прямиком в SQL - запрос
  end
  
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end  
  
  def follow!(other_user)
    relationships.create!(followed_id: other_user.id) #follower_id автоматически подставляется id нашего пользователя, потому что follower_id - внешний ключ таблицы relationships по которому мы обращаемся к элементам таблицы
    # в данном случае необязательно писать self.relationships.create!(...)
  end
  
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!    
  end
  
  private
  
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
  
  
end
