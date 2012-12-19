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
      options[:created_at] = Time.now.to_i unless options.has_key?(:created_at)
      original_new options
    end
  end

end
