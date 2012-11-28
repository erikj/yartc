class Post < RedisModel

  property :content
  property :user

  # create a post
  def self.create username, content
    id = redis.incr 'nextPostId'
    user_id = redis.get "username:#{username}:id"
    post =  Post.new id

    post.content = content
    post.user    = user_id

    user = User.new user_id
    user.posts_push post
    redis.rpush "global:posts", id
    return post
  end

end
