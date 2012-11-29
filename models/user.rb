class User < Ohm::Model

  attribute :name
  index :name
  collection :posts, :Post

end
