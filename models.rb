require 'redis'

# https://github.com/danlucraft/retwis-rb/blob/master/domain.rb

# connect to redis if needed, return redis connection
def redis
  $redis ||= Redis.new
end


class RedisModel

  attr_reader :id

  def initialize id
    @id = id
  end

  def self.property name
    klass = self.name.downcase
    self.class_eval <<-RUBY
      def #{name}
        _#{name}
      end

      def _#{name}
        redis.get("#{klass}:" + id.to_s + ":#{name}")
      end

      def #{name}=(val)
        redis.set("#{klass}:" + id.to_s + ":#{name}", val)
      end
    RUBY
  end

  def self.has_many name
    klass = self.name.downcase
    self.class_eval <<-RUBY
      def #{name}_key
        "#{klass}:" + id.to_s + ":#{name}"
      end

      def #{name}
        many = redis.lrange #{name}_key, 0, -1
        many.collect{ |m| self.new id }
      end

      def #{name}_push pushed
      # FIXME: def #{ name }<<
        puts pushed.inspect
        redis.rpush #{name}_key, pushed.id
      end
    RUBY
  end

end

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
  def posts
    post_ids = redis.lrange "user:#{id}:posts", 0, -1
    # TODO: look up posts via Post class method
    posts = Post.find post_ids
  end

end

class Post < RedisModel

  property :content

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

  def self.find input=nil

    if input.nil? or input == :all
      return self.all
    elsif input.is_a? Array
      posts = []
      input.each do |id|
        posts << Post.new( id)
      end
      return posts
    elsif input.is_a? String or input.is_a? Integer
      return Post.new input
    end
  end

  # get all the posts, e.g. for timeline
  def self.all

    post_ids = redis.lrange "global:posts", 0, -1

    posts = post_ids.collect{ |id| Post.new id }

    return posts
  end


end

