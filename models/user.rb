require 'digest'

class User < Ohm::Model

  attribute :name
  index :name
  unique :name

  attribute :email
  index :email
  # unique :email

  attribute :salt
  attribute :hashed_password

  collection :posts, :Post

  set :following, User
  set :followers, User

  def validate
    assert_present :name
    assert_length  :name, 1..64
    assert_format  :name, /^\w+$/ # [a-zA-Z0-9_]
    # assert_email   :email
  end

  # generate secure salt
  def mk_salt
    Digest::SHA1.hexdigest [Time.now.to_s, self.name, rand.to_s].join(' - ')
  end

  # generate salted password
  def hash_password password
    Digest::SHA1.hexdigest [self.salt, password].join(' - ')
  end

end
