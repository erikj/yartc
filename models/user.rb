class User < RedisModel
  has_many :posts

  def self.create username #, email
    id = redis.incr 'nextUserId'
    redis.set "username:#{username}:id", id
    # redis.hset "user:#{id}", 'name', username #, :salt=>'', :hpasswd=>''}
    redis.set "user:#{id}:name", username
    User.new id
  end

  def self.find_by_username username
    id = redis.get "username:#{username}:id"
    return nil unless id
    User.new id
  end

end
