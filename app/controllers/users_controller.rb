class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :destroy] #список действий доступных только зарегестрированным пользователям
  before_action :correct_user, only: [:edit, :update] #эти действия присуще только для одного пользователя (один пользователь не может редактировать другого)
  before_action :admin_user, only: [:destroy] # эсклюзивные действия админа
  def destroy
    User.find(params[:id]).destroy
    flash[:delete] = "User successfully deleted"
    redirect_to users_url # надо почитать чем отличается от users_path
  end
  
  def index
    @users = User.paginate(page: params[:page]) #разбивает список пользователей на страницы по 30 элементов
    #params[:page] генерирует gem will_paginate
  end
  
  def show
    @user=User.find(params[:id]) #можно заменить на correct_user так-то
  end
  
  def new
    @user = User.new
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      # Handle a successful update.
      flash[:success]="Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def create
    @user=User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to user_path(@user) #можно просто ridirect_to @user
    else 
      render 'new'
    end
  end
  
  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
    :password_confirmation) #ограничивает параметры на передачу, чтобы запретить например передачу админского поля
  end
    
  def signed_in_user
    unless signed_in?
      store_location #запись запроса перед редиректом
      redirect_to signin_path, notice: "Please sign in" #notice: можно заменить на flash[:notice], почему-то с error и success так делать нельзя
    end
  end
    
  def correct_user
    @user=User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end
    
  def admin_user
    redirect_to root_path unless current_user.admin? # метод admin? добавился автоматически после соотвествующей миграции
  end
end
