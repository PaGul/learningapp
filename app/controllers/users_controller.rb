class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :destroy, :following, :followers] #список действий доступных только зарегестрированным пользователям. В данной случае при обращении незарег пользователя к данным страницам происходит переадресация на sign_in и после входа переход на предыдушую страницу
  before_action :correct_user, only: [:edit, :update] #эти действия присуще только для одного пользователя (один пользователь не может редактировать другого)
  before_action :admin_user, only: [:destroy] # эсклюзивные действия админа
  before_action :registered_user, only: [:new, :create]
  def destroy
    unless User.find(params[:id]).admin?
      User.find(params[:id]).destroy
      flash[:successdelete] = "User successfully deleted"
    else 
      flash[:error] = "Can't delete administrator!"
    end
    redirect_to users_url
  end
  
  def index
    @users = User.paginate(page: params[:page]) #разбивает список пользователей на страницы по 30 элементов
    #params[:page] генерирует gem will_paginate
  end
  
  def show
    @user = User.find(params[:id]) #можно заменить на correct_user так-то я думаю
    @microposts = @user.microposts.paginate(page: params[:page]) #paginate — он работает даже с ассоциацией микросообщений, залезая в таблицу microposts и вытягивая оттуда нужную страницу микросообщений.
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
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
    :password_confirmation) #ограничивает параметры на передачу, чтобы запретить например передачу админского поля
  end
    
    
  def correct_user
    @user=User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end
    
  def admin_user
    redirect_to root_path unless current_user.admin? # метод admin? добавился автоматически после соотвествующей миграции
  end
  
  def registered_user
    redirect_to root_path unless current_user.nil?
  end
end
