class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user #перенаправление на страницу на которую ранее заходил незарегестрированные пользователь или если такой нет, то на профиль пользователя
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'  #ренедериться (исполняется) запрос на шаблон new-действия, однако мы остаёмся на странице действия create, поэтому 
      #render НЕ РАССМАТРИВАЕТСЯ КАК ЗАПРОС
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
  
end
