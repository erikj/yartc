require "cuba"
require "cuba/render"
require 'haml'
require 'ohm'

ENV['REDIS_URL'] = ENV['REDISTOGO_URL'] if ENV.has_key? 'REDISTOGO_URL'

Ohm.connect

Dir[ File.join File.expand_path( File.dirname __FILE__ ), 'models', '*.rb' ].each do |model_file|
  require model_file
end

Cuba.plugin Cuba::Render
Cuba.use Rack::Session::Cookie
Cuba.settings[:render][:template_engine] = "haml"

Cuba.use Rack::Static, root: 'public', urls: ['/css']

def current_user
  user = nil
  if session['user_id']
    user = User[session['user_id']]
  end
  return user
end

def find_user_by_name_or_404 username
  users = User.find :name=>username

  if users.size < 1
    session[:flash][:error] = "Cannot find user: #{username}"
    res.write view('404')
    return false
  else
    return users.first
  end
end

Cuba.define do
  session[:flash] ||= {}
  on get do

    on root do
      # if user is logged in, display user's timeline, else display global timeline
      if current_user
        # TODO: display posts of current_user and users that current_user is following
        res.write view('timeline', :posts=>current_user.posts.sort_by(:created_at, :order=>"DESC"))
      else
        res.write view('timeline', :posts=>Post.all.sort_by(:created_at, :order=>"DESC"))
      end
    end

    on 'signup' do
      res.write view('signup')
    end

    on 'login' do
      res.write view('login')
    end

    on 'logout' do
      session['user_id'] = nil
      # res.write "I am logout " + session.inspect
      res.redirect '/login'
    end

    on 'post' do
      res.write view('post')
    end

    on "follow/(\\w+)" do |username|

      users = User.find :name=>username

      if users.size < 1
        session[:flash][:error] = "Cannot find user: #{username}"
      else

        user = users.first
        if not current_user
          session[:flash][:error] = 'You must be logged in to follow a user'
        elsif user == current_user
          session[:flash][:error] = 'You cannot follow yourself'
        elsif current_user.following.include? user
          session[:flash][:error] = "You are already following #{user.name}"
        else

          begin
            # create follower/following relationships
            current_user.following.add user
            user.followers.add         current_user
            session[:flash][:success] = "You are now following #{user.name}"
          rescue Exception => e
            session[:flash][:error] = "There was an error: #{e.inspect.gsub(/</, '&lt;').gsub(/>/, '&gt;')}"
          end

        end
      end

      res.redirect "/#{username}"

    end

    on "unfollow/(\\w+)" do |username|
      users = User.find :name=>username

      if users.size < 1
        session[:flash][:error] = "Cannot find user: #{username}"
      else

        user = users.first
        if not current_user
          session[:flash][:error] = 'You must be logged in to unfollow a user'
        elsif user == current_user
          session[:flash][:error] = 'You cannot unfollow yourself'
        elsif not current_user.following.include? user
          session[:flash][:error] = "You are not following #{user.name}"
        else

          begin
            # delete follower/following relationships
            current_user.following.delete user
            user.followers.delete         current_user
            session[:flash][:success] = "You are no longer following #{user.name}"
          rescue Exception => e
            session[:flash][:error] = "There was an error: #{e.inspect.gsub(/</, '&lt;').gsub(/>/, '&gt;')}"
          end

        end
      end

      res.redirect "/#{username}"

    end

    on "(\\w+)/followers" do |username|
      if user = find_user_by_name_or_404(username)
        res.write view('followers',  {:user=>user})
      end
    end

    on '(\\w+)/following' do |username|
      if user = find_user_by_name_or_404(username)
        res.write "#{username}/following"
      end
    end

    # /:username
    # this should be last
    # if user is not found, return 404
    on "(\\w+)" do |username|
      user = User.find(:name=>username).first
      if user
        res.write view('user', {:username=>username, :user=>user})
      else
        res.status = 404
        res.write view('404')
      end
    end

  end

  on post do

    on 'signup' do
      # on param('username'), param('email'), param('password'), param('confirm_password') do |username,email,password,confirm_password|
      on param('username'), param('password'), param('confirm_password') do |username, password, confirm_password|
        if password == confirm_password
          user = User.new :name=>username #, :email=>email
          user.salt = user.mk_salt
          user.hashed_password = user.hash_password password
          if user.save
            session['user_id'] = user.id
            res.redirect '/'
          else
            res.write "error: #{user.errors.inspect}"
          end
        else
          res.write "error: passwords must match"

        end
        session[:flash][:success] = "User #{user.name} successfully created"
      end

      # catchall for missing params
      on true do
        session[:flash][:error] = "Missing Required Parameters"
        res.write view('signup')
      end
    end

    on 'login' do
      on param('username'), param('password'), param('remember-me') do |username,password,remember_me|
        # look-up user based on params[]
        user = User.find(:name=>username).first
        if user
          # set session cookie
          session['user_id'] = user.id
          session[:requester] = env['REMOTE_ADDR']
          session[:flash][:success] = "Successfully logged in as #{user.name}"
          # TODO: set cookie expiration based on remember_me
          # res.write [username,password,remember_me, session.inspect].join(' | ')
          res.redirect '/'
        else
          session[:flash][:error] = "Unable to find user #{username}"
          res.redirect '/login'
        end
      end

      # catchall for missing params
      on true do
        session[:flash][:error] = "Missing Required Parameters"
        res.write view('login')
      end
    end

    on 'post' do

      on param('content') do |content|
        begin
          post = Post.new :content=>content, :user=>current_user

          if post.save and post.errors.empty?
            session[:flash][:success] = "post successfully created"
            res.redirect '/'
          else
            session[:flash][:error] = "Error Creating Post: " + post.errors.inspect
          end
        rescue Exception=>e
          session[:flash][:error] = "Error Creating Post: " + e.inspect.gsub(/</, '&lt;').gsub(/>/, '&gt;')
        end
        res.write view('post') if session[:flash].has_key? :error

      end

      # catchall for missing params
      on true do
        session[:flash][:error] = "Missing Required Parameters"
        res.write view('post')
      end
    end

  end
end