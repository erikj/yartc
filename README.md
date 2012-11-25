# redis-twitter-clone

## Idea

Build Twitter clone based on:
<http://redis.io/topics/twitter-clone>

Using Redis for datastore and Cuba + Coffeescript for web interface

## Schema

    user:<id>:name - <string>
    user:<id>:email - <string>
    user:<id>:salt - <string>
    user:<id>:hashed_password - <string>

    user:<id>:followers - <list user IDs>
    user:<id>:following - <list user IDs>
    user:<id>:posts - <list, post IDs>

    post:<id> - <string>, format: "<user-id>|<time>|content", or JSON?

## Models

create `RedisModel` based on <https://github.com/danlucraft/retwis-rb/blob/master/domain.rb>

```
class User < RedisModel
end
class Post < RedisModel
```
## Reference

- <http://redis.io/topics/data-types>
- <http://redis.io/topics/twitter-clone>
- <https://github.com/redis/redis-rb>
- <http://jimneath.org/2011/03/24/using-redis-with-ruby-on-rails.html>
- <https://github.com/danlucraft/retwis-rb>

## Load and benchmark w/ random data

<http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby>

    [molecule@air] time ruby -e "puts (0...2560000).map{65.+(rand(26)).chr}.join()">/dev/null 
    real	0m2.350s
    [molecule@air] rvm use ruby-1.9.2-p318
    [molecule@air] time ruby -e "puts (0...2560000).map{65.+(rand(26)).chr}.join()">/dev/null  
    real	0m1.513s
