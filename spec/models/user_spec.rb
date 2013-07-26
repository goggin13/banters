require 'spec_helper'

describe User do

  before do
    @valid_attrs = {
      username: 'matt',
      email: 'matt@example.com',
      password: 'password',
      bio: 'Hello World'
    }
  end

  describe "with valid attributes" do
    it "creates a new user" do
      # expect do
        user = User.create! @valid_attrs
      # end.to change(User, :count).by 1
      user.username.should == 'matt'
      user.email.should == 'matt@example.com'
      user.bio.should == 'Hello World'
      user.id.should_not be_nil
    end
  end

  describe "with invalid attributes" do
    it "requires a username" do
      User.new(@valid_attrs.merge(username: nil)).should_not be_valid
    end

    it "requires an email" do
      User.new(@valid_attrs.merge(email: nil)).should_not be_valid
    end
  end

  describe "passwords" do
    it "requires a password if none has been set yet" do
      User.new(@valid_attrs.merge(password: nil)).should_not be_valid
    end

    it "does not require a password if a user already has set one" do
      user = User.create! @valid_attrs
      user.password = nil
      user.should be_valid
    end

    it "sets a hashed password after password has been set" do
      user = User.create! @valid_attrs
      user.hashed_password.should_not be_nil
    end

    it "sets a salt after password has been set" do
      user = User.create! @valid_attrs
      user.salt.should_not be_nil
    end
  end

  describe "has_password?" do
    it "should return true if the user has the password" do
      user = User.create! @valid_attrs
      user.has_password?("password").should be_true
    end

    it "should return false if the user does not have the password" do
      user = User.create! @valid_attrs
      user.has_password?("bad_password").should be_false
    end
  end

  describe "self.authenticate" do
    before do
      @user = User.create! @valid_attrs
    end

    it "returns the user with correct username and password" do
      User.authenticate("matt", "password").should == @user
    end

    it "returns the user with correct email and password" do
      User.authenticate("matt@example.com", "password").should == @user
    end

    it "returns nil with a non-existant username" do
      User.authenticate("NOT-A-USERNAME", "password").should be_nil
    end

    it "returns nil with the incorrect password" do
      User.authenticate("matt", "bas_password").should be_nil
    end
  end

  describe "avatar_file=" do
    before do
      @user = User.create! @valid_attrs
      @file = File.new('spec/fixtures/hyperdex.png', 'r')
      @stub = stub_request(:post, "https://api.cloudinary.com/v1_1/banters/image/upload")
       .to_return(body: {
        "url" => 'http://res.cloudinary.com/demo/image/upload/v1371281596/sample.jpg',
        "secure_url" =>
        'https://cloudinary-a.akamaihd.net/demo/image/upload/v1371281596/sample.jpg',
          "public_id" => 'sample-public-id',
          "version" => '1312461204',
          "format" => 'jpg',
          "width" => 864,
          "height" => 564,
          "bytes" => 120253
      }.to_json)
    end

    it "hits the cloudinary API" do
      @user.avatar_file = @file
      @stub.should have_been_requested
    end

    it "sets the avatar_id" do
      @user.avatar_file = @file
      @user.avatar_id.should == "sample-public-id.jpg"
    end
  end
end
