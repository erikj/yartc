class User < Ohm::Model

  attribute :name
  index :name
  unique :name

  attribute :email
  index :email
  unique :email

  collection :posts, :Post

  def validate
    assert_present :name
    assert_length  :name, 1..64
    assert_format  :name, /^\w+$/ # [a-zA-Z0-9_]
    assert_email   :email
  end

end
