class Post < Ohm::Model

  attribute :content
  reference :user, :User
  attribute :created_at
  index     :created_at

  def validate
    assert_numeric :user_id
    assert_length  :content, 1..140
    assert_numeric :created_at
    assert_length  :created_at, 8..12
  end

  class << self
    alias_method :original_new, :new
    def new options={}
      post = original_new options
      post.created_at = Time.now.to_i unless post.created_at
      return post

    end
  end

end
