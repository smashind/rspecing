FactoryGirl.define do 
	factory :user do
		name      "Mark Sinclair"
		email     "mr.marksinclair@gmail.com"
		password  "foobar"
		password_confirmation "foobar"
	end
end