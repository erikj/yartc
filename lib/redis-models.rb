require 'redis'

# https://github.com/danlucraft/retwis-rb/blob/master/domain.rb

# connect to redis if needed, return redis connection
def redis
  $redis ||= Redis.new
end

# TODO: move to lib/redis-model.rb

class RedisModel

  attr_reader :id

  def initialize id
    @id = id
  end

  # finders
  def self.find input=nil

    if input.nil? or input == :all
      return self.all
    elsif input.is_a? Array
      posts = []
      input.each do |id|
        posts << self.new( id)
      end
      return posts
    elsif input.is_a? String or input.is_a? Integer
      return self.new input
    end
  end

  # get all the elements, e.g. posts for timeline
  def self.all
    # TODO: move to and call find :all
    post_ids = redis.lrange "global:#{self.name.downcase}s", 0, -1
    posts = post_ids.collect{ |id| self.new id }
    return posts
  end

  # can properties be better implemented as key-value pairs of hashes?
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

  # TODO: has_many name, klass=nil (?)
  # e.g. User.has_many followers, User
  # e.g. User.has_many following, User
  def self.has_many name
    klass = self.name.downcase
    self.class_eval <<-RUBY
      def #{name}_key
        "#{klass}:" + id.to_s + ":#{name}"
      end

      def #{name}
        has_many_class = Kernel.const_get '#{name}'.to_s.gsub(/(s)$/, '').to_s.capitalize
        many = redis.lrange #{name}_key, 0, -1
        many.collect{ |m| has_many_class.new m }
      end

      def #{name}_push pushed
      # FIXME: def #{ name }<<
        puts pushed.inspect
        redis.lpush #{name}_key, pushed.id
      end
    RUBY
  end

end
