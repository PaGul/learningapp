require 'spec_helper'

describe "Users" do
  
  subject { page }
  describe "Sign up" do
    before {visit signup_path}
    it {should have_title(full_title('Sign up'))}
    it {should have_content('Sign up')}
  end
  describe "profile page" do
  
    #user определен в факторигёрл
    let(:user) {FactoryGirl.create(:user)}
    before {visit user_path(user)}
  
    it {should have_content(user.name)}
    it {should have_title(user.name)}
  end
  describe "signup page" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
      
      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
    end
    
    describe "blank name" do 
      before do
        fill_in "Name", with: ""
        click_button submit
      end
    
      it {should have_content("Name can't be blank")}
    end
    
    describe "errors of filling the labels" do
      describe "blank email" do 
        before do 
          fill_in "Email", with: ""
          click_button submit
        end
    
        it {should have_content("Email can't be blank")}
      end
    
      describe "wrong email" do 
        before do
          fill_in "Email", with: "foobar@host"
          click_button submit
        end
  
        it {should have_content("Email is invalid")}
      end
    
      describe "already taken email" do 
        let(:user) {FactoryGirl.create(:user)}  
        before do
          user.save
          fill_in "Email", with: "zagerpaul@gmail.com"
          click_button submit
        end

        it {should have_content("Email has already been taken")}
      end
  
      describe "blank password" do 
        before do
          fill_in "Password", with: ""
          click_button submit
        end
      
        it {should have_content("Password can't be blank")}
      end
    
      describe "short password" do 
        before do
          fill_in "Password", with: "1234"
          click_button submit
        end
  
        it {should have_content("Password is too short (minimum is 6 characters)")}
      end
    
      describe "wrong confirmation" do 
        before do
          fill_in "Password", with: "12121212"
          fill_in "Confirmation", with: "34343434"
          click_button submit
        end
        it {should have_content("Password confirmation doesn't match Password")}
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end
end

