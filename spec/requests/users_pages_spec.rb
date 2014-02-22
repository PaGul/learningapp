require 'spec_helper'

describe "Users" do
  
  subject { page }
  
  describe "index" do
    
    let(:user) { FactoryGirl.create(:user) }
  
    before(:each) do #противоположность before(:all), см. ниже
      sign_in user
      visit users_path
    end
    
    it { should have_title('All users') }
    it { should have_content('All users') }
    
    describe "pagination" do
      # before(:all) гарантирует создание образцовых пользователей единожды перед всеми тестами блока.
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }
        
      it { should have_selector('div.pagination') }
    
      it "should list each user" do
        User.paginate(page: 1).each do |user|  
          #User.paginate(page: 1): вытягивает первую страницу пользователей из базы данных.
          expect(page).to have_selector('li', text: user.name)
        end
      end 
    end
    
    describe "delete links" do
      it { should_not have_link('delete') } # пользователь не может удалять пользователей
      
      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end
        it { should have_link('delete', user_path(User.first)) }
        it "should able to delete user" do
          expect do
            click_link('delete', match: :first) # match: :first, который говорит Capybara что нам не важно какую именно удаляющую ссылку она (Капибара) кликает; это должен быть просто клик по первой из тех что она видит
          end.to change(User, :count).by(-1)
        end
        
        
        describe "it shouldn't able to delete administrator" do
          before do
            visit users_path
            delete user_path(admin)
          end
          it "number of users shouldn't change" do
            expect { delete user_path(admin) }.to_not change(User, :count).by(-1) #почему-то капибара не делает анализ респонда
          end
        end
        
        #   it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end
  
  describe "Sign up" do
    before { visit signup_path }
    it { should have_title(full_title('Sign up')) }
    it { should have_content('Sign up') }
  end
  
  describe "profile page" do
  
    #user определен в факторигёрл
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }
  
    before { visit user_path(user) }
  
    it { should have_content(user.name) }
    it { should have_title(user.name) }
    
    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end
    
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
    
      it { should have_content("Name can't be blank") }
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
        let(:user) {FactoryGirl.create(:user, email: "zagerpaul@gmail.com")}  
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

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end
  
  describe "edit" do
    let(:user){ FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user) 
    end 
    
    describe "forbidden attributes" do # нельзя стать админом через patch
      let(:params) do
        { user: {:password => user.password, :password_confirmation => user.password, :admin => true } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end
    
    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end
    
    describe "with valid information" do
      let(:new_name) { "NewName" }
      let(:new_email) { "new@example.com"}
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirmation",     with: user.password
        click_button "Save changes"
      end
      
      it { should have_content("NewName") }
      it { should have_link('Sign out', href: signout_path) }
      it { should have_selector('div.alert.alert-success')}
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
      
    end
    
    describe "with invalid information" do
      before { click_button "Save changes" }
      
      it { should have_content('error') }
      
    end
  end
end

