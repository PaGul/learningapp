require 'spec_helper'

describe "Static pages" do
  
  let(:btitle) {"Ruby on Rails Tutorial Sample App"}
  
  subject {page}  #субъект тестирования
  
  shared_examples_for "Static standart headings" do
    it {should have_selector('h1', text: heading)}
    it {should have_title(full_title(heading))}
  end
  
  describe "Home page" do #не использовал стандартный обработчик заголовков, т.к. пришлось бы вводить 2 отдельные переменные для заголовка и тайтла
    before {visit root_path}
    it {should have_content ('Home')}
    it {should have_title("#{btitle}")}
    it {should_not have_title("| Home")}
    it "should have the right links on the layout" do
      visit root_path
      click_link "About"
      expect(page).to have_title(full_title('About Us'))
      click_link "Help"
      expect(page).to have_title(full_title('Help'))
      click_link "Contact"
      expect(page).to have_title(full_title('Contact'))
      click_link "Home"
      expect(page).to have_content("Welcome")
      click_link "Sign me up!"
      expect(page).to have_title(full_title('Sign up'))
      click_link "sample app"
      expect(page).to have_content("Welcome")
    end
  end

  describe "Help page" do
    before {visit help_path}
    let(:heading) {'Help'}
    it_should_behave_like "Static standart headings"
  end

  describe "About page" do
    before {visit about_path}
    let(:heading){'About Us'}
    it_should_behave_like "Static standart headings"
  end
  describe "Contact" do
    before {visit contact_path}
    let(:heading){'Contact'}
    it_should_behave_like "Static standart headings"
  end
  
end