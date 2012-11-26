require 'redis'

# https://github.com/danlucraft/retwis-rb/blob/master/domain.rb

# connect to redis if needed, return redis connection
def redis
  $redis ||= Redis.new
end


class RedisModel

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

  def self.find_by_username username
    id = redis.get "username:#{username}:id"
    return nil unless id
    User.new id
  end
  def posts
    post_ids = redis.lrange "user:#{id}:posts", 0, -1
    posts = post_ids.collect{ |id| { :id=>id, :content=> redis.get( "post:#{id}:content" ) } }
  end

end

class Post < RedisModel

  # create a post
  def self.create username, content
    id = redis.incr 'nextPostId'
    user_id = redis.get "username:#{username}:id"
    redis.set "post:#{id}:content", content
    redis.set "post:#{id}:user", user_id
    redis.rpush "user:#{user_id}:posts", id
    redis.rpush "global:posts", id
    Post.new id
  end

  # get all the posts, e.g. for timeline
  def self.all

    post_ids = redis.lrange "global:posts", 0, -1

    posts = post_ids.collect{ |id| { :id=>id, :content=> redis.get( "post:#{id}:content" ) } }

    return posts
  end


end

