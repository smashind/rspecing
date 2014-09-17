require 'spec_helper'

describe "MicropostPages" do
  
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

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

  		it "should delete a micropost" do 
  			expect { click_link "delete" }.to change(Micropost, :count).by(-1)
  		end
  	end
  end

  describe "micropost count" do 

  	describe "with one post" do 
  		before { FactoryGirl.create(:micropost, user: user) }
  		before { visit root_path }

  		it "should say 1 micropost" do 
  			expect(page).to have_content("1 micropost")
  		end
  	end

  	describe "with more than one post" do 
  		before { FactoryGirl.create(:micropost, user: user) }
  		before { FactoryGirl.create(:micropost, user: user) }
  		before { visit root_path }

  		it "should say 2 microposts" do 
  			expect(page).to have_content("2 microposts")
  		end
  	end
  end
end
