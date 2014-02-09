require 'spec_helper'

describe User do
  before {@user=User.new(name: "example", email: "example@example.com", password: "gulpass", password_confirmation: "gulpass")}
  subject{@user}
  it {should respond_to(:name)}  #объект юзер отвечает на методы
  it {should respond_to(:email)}
  it {should respond_to (:password_digest)}
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it {should be_valid}
  
describe "test for the empty name" do
  before {@user.name=" "}
  it {should_not be_valid}
end

describe "name shouldn't be very long" do
  before {@user.name="a" * 56}
  it {should_not be_valid}
end
  describe "right test email format" do
    before {@user.email="3@fdsf.com"}
    it {should be_valid}
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

end


