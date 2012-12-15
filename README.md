# Yet Another Redis-Twitter Clone

## Concept

Build Twitter clone based on:
<http://redis.io/topics/twitter-clone>
to try out integration of various interesting technologies:

### Technologies

- datastore:
  - Redis

- web interface
  - Cuba
  - Coffeescript
  - HAML

- host:
  - Heroku

- datastore persistence
  - postgresql
  - exports / imports via rake tasks

## Models

Using [**ohm** Object-hash mapping library for Redis](http://soveran.github.com/ohm/)

### Schema

Defined in `models/*.rb` and handled by **ohm**

## TODO: Actions

### /

timeline of posts

`global:posts` - list of post IDs

### /user POST params

create user

### /login GET

display login form

### /login POST

log user in

### /:username

`:username` user's posts

### /:username/follow

### /:username/unfollow

### /:username/following

### /:username/followers

### /:username/mentions

### /post/:id

### /post POST params

posts a message

## References

- <http://redis.io/topics/data-types>
- <http://redis.io/topics/twitter-clone>
- <https://github.com/redis/redis-rb>
- <http://jimneath.org/2011/03/24/using-redis-with-ruby-on-rails.html>
- <https://github.com/danlucraft/retwis-rb>

## TODO: Load and benchmark w/ random data

<http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby>

    [molecule@air] time ruby -e "puts (0...2560000).map{65.+(rand(26)).chr}.join()">/dev/null 
    real	0m2.350s
    [molecule@air] rvm use ruby-1.9.2-p318
    [molecule@air] time ruby -e "puts (0...2560000).map{65.+(rand(26)).chr}.join()">/dev/null  
    real	0m1.513s

## License

This software is licensed under the [MIT license](http://opensource.org/licenses/MIT). For more information, see `LICENSE.txt`.