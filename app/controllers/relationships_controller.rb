class RelationshipsController < ApplicationController
  before_action :signed_in_user
  
  def create # params[:relationship][:followed_id] передаётся через скрытое поле формы, см. _follow.html.erb
    @user = User.find(params[:relationship][:followed_id]) # при нажатии кнопки, см. _follow.html.erb
    current_user.follow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js # в данном случае подключение ajax для кнопки follow
    end
  end
  
  def destroy
    @user = Relationship.find(params[:id]).followed 
    # в params[:id] содержится id найденной пары follower_id(которая current_user.id) и followed_id (которая user данной страницы). Пара была вычислена в _unfollow.html.erb
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js  # в данном случае подключение ajax для кнопки unfollow
    end
  end
end
    