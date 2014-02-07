require 'spec_helper'

describe "Users" do
  
  subject { page }
  describe "Sign up" do
    before {visit signup_path}
    it {should have_title(full_title('Sign up'))}
    it {should have_content('Sign up')}
  end
end