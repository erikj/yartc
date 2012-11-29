class Post < Ohm::Model

  attribute :content
  reference :user, :User

end
