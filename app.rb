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

Cuba.use Rack::Static, root: 'public', urls: ['/css']

def current_user
  user = nil
  if session['user_id']
    user = User[session['user_id']]
  end
  return user
end

Cuba.define do
  on get do

    on root do
      # if user is logged in, display user's timeline, else display global timeline
      res.write render('views/layout.haml') {
        if current_user
          # TODO: display posts of current_user and users that current_user is following
          render( 'views/timeline.haml', :posts=>current_user.posts.sort_by(:created_at, :order=>"DESC") )
        else
          render( 'views/timeline.haml', :posts=>Post.all.sort_by(:created_at, :order=>"DESC") )
        end
      }
    end

    on 'signup' do
      res.write render('views/layout.haml') { render 'views/signup.haml' }
    end

    on 'login' do
      res.write render('views/layout.haml') { render 'views/login.haml' }
    end

    on 'logout' do
      session['user_id'] = nil
      # res.write "I am logout " + session.inspect
      res.redirect '/login'
    end

    # /:username
    # this should be last
    # if user is not found, return 404
    on "(\\w+)" do |username|
      user = User.find(:name=>username).first
      if user
        res.write render('views/layout.haml') { render( 'views/user.haml', {:username=>username, :user=>user}) }
      else
        res.status = 404
        # TODO: move to dedicated 404 page
        res.write render('views/layout.haml') { "<h1>404: Not Found</h1>" }
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
        # TODO: populate flash message w/ 'success'
      end

      # catchall for missing params
      on true do
        res.write render('views/layout.haml') { "oops!"}
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
          # TODO: set cookie expiration based on remember_me
          # res.write [username,password,remember_me, session.inspect].join(' | ')
          res.redirect '/'
        else
          res.redirect '/login'
        end
      end

      # catchall for missing params
      on true do
        res.write render('views/layout.haml') { "oops!"}
      end
    end

  end

end