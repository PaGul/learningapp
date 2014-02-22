require 'spec_helper' # в этих тестах анализируется запись юзера в БД

describe User do
  before { @user=User.new(name: "example", email: "example@example.com", password: "gulpass", password_confirmation: "gulpass") }
  
  subject{ @user }
  
  it { should respond_to(:name) }  #объект юзер имеет поля или методы
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  
  it { should be_valid }
  it { should_not be_admin } # пользователь должен иметь булев метод admin?
  
  describe "with admin attribute set'true" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end
    it { should be_admin }
  end
  
  describe "test for the empty name" do
    before { @user.name=" " }
    it {should_not be_valid}
  end

  describe "name shouldn't be very long" do
    before { @user.name="a" * 56 }
    it { should_not be_valid }
  end
  describe "wrong test email format" do
    before { @user.email="3@fdsf..com" }
    it { should_not be_valid }
  end

  describe "when email was duplicated" do
    before do 
      user2=@user.dup
      user2.email=@user.email.upcase
      user2.save  #сохраняю второго юзера в бд, потому что в тестах сравниваю первого юзера со всем остальным контентом
    end
    it {should_not be_valid}
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password is not confirm" do
    before {@user.password_confirmation = "foobar"}
    it {should_not be_valid}  
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) } #let - is anonymus method with name, lol

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false } #it and specify is the same command
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "ExamPle@exAMple.cOm" }
    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank } 
    #it { expect(@user.remember_token).not_to be_blank }
  end
  
  describe "micropost associations" do
    before { @user.save }
    let!(:older_micropost) do #let вычисляются сразу после обращения, let! вычисляется сразу после объявления
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) 
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end
    
    it "should have right microposts in he right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end
    
    it "should destroy associated microposts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty #при удалении пользователя не должна очиститься переменная micropost
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty #если объект не найден obj.find возвращает исключение(to raise_error(ActiveRecord::RecordNotFound)), а obj.where - nil 
      end
    end
    
    describe "status" do # feed should only have his messages, no unfollowed user posts
      let(:unfollowed_micropost) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }
      
      its(:feed) { should include(newer_micropost) } # проверяет есть ли newer post в массиве feed
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_micropost) }
    end
    
  end

end


