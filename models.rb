require 'redis'

# https://github.com/danlucraft/retwis-rb/blob/master/domain.rb

class RedisModel
  # connect to redis if needed, return redis connection
  def self.redis
    $redis ||= Redis.new
  end

  attr_reader :id

  def initialize(id)
    @id = id
  end

  # def self.property(name)
  #   klass = self.name.downcase
  #   self.class_eval <<-RUBY
  #     def #{name}
  #       _#{name}
  #     end

  #     def _#{name}
  #       redis.get("#{klass}:id:" + id.to_s + ":#{name}")
  #     end

  #     def #{name}=(val)
  #       redis.set("#{klass}:id:" + id.to_s + ":#{name}", val)
  #     end
  #   RUBY
  # end

end

class User < RedisModel
  def self.create username #, email
    id = redis.incr 'nextUserId'
    redis.set "username:#{username}:id", id
    # redis.hset "user:#{id}", 'name', username #, :salt=>'', :hpasswd=>''}
    redis.set "user:#{id}:name", username
    User.new id
  end

end

class Post < RedisModel
  def self.create username, content
    id = redis.incr 'nextPostId'
    user_id = redis.get "username:#{username}:id"
    redis.set "post:#{id}:content", content
    redis.set "post:#{id}:user", user_id
    redis.rpush "user:#{user_id}:posts", id
    Post.new id
  end
end

