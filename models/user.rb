class User < Ohm::Model

  attribute :name
  index :name
  collection :posts, :Post

  def validate
    assert_present :name
    assert_length  :name, 1..64
    # assert_email :email
  end

end
