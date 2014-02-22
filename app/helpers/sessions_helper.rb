module SessionsHelper
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user #вызываем метод current= модуля SessionsHelper 
  end
  

  def signed_in?
    !current_user.nil?
  end
  
  def current_user=(user)
    @current_user = user
  end

  def current_user  #в HTTP отсутствует сохранение промежуточного состояния между парами «запрос-ответ» — когда пользователь делает второй запрос, все переменные устанавливаются к своим дефолтным значениям, в случае переменных экземпляра вроде @current_user это nil.
    #короче штука считается только один раз
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end
  
  def current_user? (user)
    user==current_user
  end
  
  def sign_out
    current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token)) #вызывается переменная current user. я запутался
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def redirect_back_or(default)
    redirect_to (session[:return_to] || default)
    session.delete(:return_to)
  end
  
  def store_location #сохраняет запрашиваемую страницу незарегистрированного пользователя перед перенаправлением на страницу аутотенфикации
    session[:return_to]=request.url if request.get?
  end
  
  def signed_in_user
    unless signed_in?
      store_location #запись запроса перед редиректом
      redirect_to signin_path, notice: "Please sign in" #notice: можно заменить на flash[:notice], почему-то с error и success так делать нельзя
    end
  end

end
