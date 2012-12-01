class Post < Ohm::Model

  attribute :content
  reference :user, :User
  attribute :created_at
  index     :created_at

  def validate
    assert_numeric :user_id
    assert_length :content, 1..140
    assert_numeric :created_at
    assert_length  :created_at, 8..12
  end

  class << self
    # FIXME: this doesn't apply :created_at when Post is created via Post::new(); Post#save()
    alias_method :original_create, :create
    def create options={}
      options[:created_at] = Time.now.to_i unless options.has_key?(:created_at)
      original_create options
    end
  end

end
