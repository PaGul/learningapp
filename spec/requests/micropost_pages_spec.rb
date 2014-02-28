require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before(:each) { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end
  
  describe "micropost destruction" do 
    before { FactoryGirl.create(:micropost, user: user) }
    
    describe "as correct user" do
      before { visit root_path }
      
      it "should delete micropost" do
        expect{ click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
    
    describe " as another user" do
      let(:another_user) { FactoryGirl.create(:user) }
      before do
        click_link('Sign out')
        sign_in another_user
        visit user_path(user)
      end
      it { should_not have_link('delete') }
    end
  end
  
  describe "many microposts" do 
    before do
      40.times { FactoryGirl.create(:micropost, user: user) }
      visit root_path
    end
    after { user.microposts.delete_all }
    describe "pagination" do
      it { should have_selector('div.pagination') }
    end
    
    describe "number in the sidebar" do
      it { should have_content("40 microposts") }
    end
  end
end