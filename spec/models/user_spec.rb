require 'spec_helper'

describe User do					# Different tasks to perform on User instance
 
   before do 						# New user instance constructed with attributes
     @user= User.new(	name: "Example User", 
			email: "user@example.com", 
			password: "foobar", 
			password_confirmation: "foobar"
		     )
   end
   
   subject { @user }					# User must follow expected behaviour
  
   	it { should respond_to (:name) }
   	it { should respond_to (:email) }
   	it { should respond_to(:password_digest) }
   	it { should respond_to(:password) }
   	it { should respond_to(:password_confirmation) }
   	it { should respond_to(:authenticate) }

	it { should be_valid }				# Finally all should be valid 

# What to do in a situation when password is not present?
   describe "when password is not present" do
     before do
       @user = User.new(name: "Example User", email: "user@example.com",
                        password: " ", password_confirmation: " ")
     end
       it { should_not be_valid }			# User must not be valid 
   end

# What to do when password is confirmed in a valid way?
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

# When a password is too short than 6 characters?
  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

# What is the result of email authentication?
  describe "return value of authenticate method" do
      before { @user.save }
      let(:found_user) { User.find_by(email: @user.email) }

      describe "with valid password" do
        it { should eq found_user.authenticate(@user.password) }
      end

      describe "with invalid password" do
        let(:user_for_invalid_password) { found_user.authenticate("invalid") }

        it { should_not eq user_for_invalid_password }
        specify { expect(user_for_invalid_password).to be_false }
      end
  end

# What to do when name field is empty?
  describe "when a name is not present" do
     before { @user.name = ""}
      it { should_not be_valid}
  end 
 
# What to do when name is too long as specified?
   describe "when name is too long" do
     before { @user.name = "a"*51 }
     it { should_not be_valid }
   end 

# What to do when email is not present at all NOT empty.
   describe "when email is not present" do
     before { @user.email = ""}
     it { should_not be_valid }
   end

# What to do when email is already taken by some one else? It checks on duplication..
   describe "when email address is already taken" do
     before do
       user_with_same_email = @user.dup
       user_with_same_email.email = @user.email.upcase
       user_with_same_email.save
     end
       it { should_not be_valid }
   end

# What to do when email format is invalid? 
   describe "when email format is invalid" do
      it "should be invalid" do
         addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
         addresses.each do |invalid_address|
           @user.email = invalid_address
           expect(@user).not_to be_valid
         end
       end
    end

# What to do when email format is valid? Valid formats are specified in REGEX
    describe "when email format is valid" do
        it "should be valid" do
          addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
           addresses.each do |valid_address|
             @user.email = valid_address
              expect(@user).to be_valid
           end
         end
     end
end
