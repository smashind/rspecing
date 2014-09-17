require 'spec_helper'

describe "User Pages" do

  subject { page }

  describe "index" do 
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do 
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do 

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do 
        User.paginate(page: 1).each do |user| 
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end
  end

  # fhj: I could not get this to work as done in the book (i.e. placing this
  # above inside the "index" block). It could not execute sign_in admin
  # because it was already signed in as a non-admin user. I tried the
  # suggestion to create a sign_out helper function, but I could not make
  # that work either. By moving it outside of the block and recreating
  # the 30 test users, I was able to get it to pass the tests.
  # I also created the "non-admin user should not have delete links" block
  # at the end of the "pagination" block above to test for that case properly.
  describe "delete links" do

    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all)  { User.delete_all }

    describe "as an admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
        sign_in admin
        visit users_path
      end

      it { should have_link('delete', href: user_path(User.first)) }
      it "should be able to delete another user" do
        expect do
          click_link('delete', match: :first)
        end.to change(User, :count).by(-1)
      end
      it { should_not have_link('delete', href: user_path(admin)) }
    end
  end

  describe "profile page" do 
  	let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }

  	it { should have_content(user.name) }
  	it { should have_title(user.name) }
  end

  describe "signup page" do
  	before { visit signup_path }

  	it { should have_selector('h1', :text => 'Sign up') }
  	it { should have_title(full_title('Sign up')) }
  end

  describe "signup" do 
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
  			it { should have_selector('div.alert.alert-success', text:'Welcome') }

  			describe "followed by signout" do 
	  			before { click_link "Sign out" }
	  			it { should have_link('Sign in') }
  			end
  		end
  	end
  end

  describe "edit" do 
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user) 
    end

    describe "page" do 
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do 
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do 
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do 
        fill_in "Name",              with: new_name
        fill_in "Email",             with: new_email
        fill_in "Password",          with: user.password 
        fill_in "Confirmation",  with: user.password 
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end

  describe "profile page" do 
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

    describe "deleting a micropost" do 

      describe "as incorrect user" do
        before { visit user_path(user) } 

        it "should not see a delete link" do 
          expect(page).not_to have_selector(:link, 'delete')
        end
      end
    end
  end

  describe "micropost pagination" do 
    let(:user) { FactoryGirl.create(:user) }
    before { 50.times { FactoryGirl.create(:micropost, user: user, content: "le post") } }
    after(:all)  { user.microposts.delete_all }
    
    before { visit user_path(user) }

    it { should have_selector('div.pagination') }

    it "should list each micropost" do 
       user.microposts.paginate(page: 1).each do |micropost| 
         expect(page).to have_selector('li', text: micropost.content)
       end
    end
  end
end
