class Post < Ohm::Model

  attribute :content
  reference :user, :User
  attribute :created_at
  index     :created_at

  def validate
    assert_present :user_id
    assert_numeric :user_id
  end

  class << self
    alias_method :original_create, :create

    def create options={}
      options[:created_at] = Time.now.to_i unless options.has_key?(:created_at)
      original_create options
    end
  end

end
