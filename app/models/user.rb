class User
  include HyperMapper::Document

  attr_accessor :password

  # Determines, as in Rails, which attributes can be modified via mass assignment
  attr_accessible :username, :bio, :email, :password

  # HyperMapper will generate a unique ID the first time this
  # User is saved
  autogenerate_id

  attribute :username
  attribute :email
  attribute :bio
  attribute :avatar_id

  # Things we'll need for authentication
  attribute :salt
  attribute :hashed_password
  attribute :session_id

  # Maintain :created_at and :updated_at timestamps
  timestamps

  validates_presence_of :email
  validates_presence_of :username
  validates :password, presence: true, if: "hashed_password.blank?"

  before_save :encrypt_password, if: "!password.nil?"

  def encrypt_password
    self.salt ||= Digest::SHA256.hexdigest("#{Time.now.to_s}-#{username}")
    self.hashed_password = encrypt(password)
  end

  def encrypt(raw_password)
    Digest::SHA256.hexdigest("-#{salt}-#{raw_password}")
  end

  def has_password?(raw_password)
    hashed_password == encrypt(raw_password)
  end

  def avatar_file=(io)
    result = Cloudinary::Uploader.upload(io)
    self.avatar_id = "#{result['public_id']}.jpg"
  end

  def self.authenticate(username, plain_text_password)
    user = User.where(username: username)[0]
    user ||= User.where(email: username)[0]
    return nil unless user && user.has_password?(plain_text_password)
    user
  end
end
