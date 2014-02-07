require 'spec_helper'

describe "Static pages" do
  

  subject {page}
  describe "Home page" do
    before {visit root_path}
    it {should have_content ('Home')}
    it {should have_title("#{btitle}")}
    it {should_not have_title("| Home")}
  end

  describe "Help page" do
    before {visit help_path}
    it {should have_content ('Help')}
    it {should have_title(full_title('Help')) }
  end

  #старый способ записи
    let(:btitle) {"Ruby on Rails Tutorial Sample App"}
  describe "About page" do
    before {visit about_path}
    it {should have_content('About Us')}
    it {should have_title(full_title('About Us'))}
  end
  describe "Contact" do
    before {visit contact_path}
    it {should have_content('Contact')}
    it {should have_title(full_title('Contact'))}
  end
  
end