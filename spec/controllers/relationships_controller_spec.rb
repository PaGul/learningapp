require 'spec_helper'

describe RelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user, no_capybara: true }

  describe "creating a relationship with Ajax" do

    it "should increment the Relationship count" do
      expect do # XHR - XmlHttpRequest
        xhr :post, :create, relationship: { followed_id: other_user.id } # xhr не работает в интеграционных тестах.   xhr принимает в качестве аргумента символ для соответствующего метода HTTP, символ для действия и хэш представляющий собой содержимое params в самом контроллере
      end.to change(Relationship, :count).by(1)
    end

    it "should respond with success" do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      expect(response).to be_success
    end
  end

  describe "destroying a relationship with Ajax" do
    before { user.follow!(other_user) }
    let(:relationship) { user.relationships.find_by(followed_id: other_user.id) } #в follower_id автоматически записывается user.id так как relationship - has_many ассоциация (см. models/user.rb)
    
    it "should decrement the Relationship count" do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end

    it "should respond with success" do
      xhr :delete, :destroy, id: relationship.id
      expect(response).to be_success
    end
  end
end