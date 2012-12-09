require "cuba"
require "cuba/render"
require 'haml'
require 'ohm'

Ohm.connect

Dir[ File.join File.expand_path( File.dirname __FILE__ ), 'models', '*.rb' ].each do |model_file|
  require model_file
end

Cuba.plugin Cuba::Render
Cuba.use Rack::Session::Cookie

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

    css_dir = 'css'
    on css_dir, extension('css') do |file|
      res.headers["Content-Type"] = "text/css; charset=utf-8"
      res.write File.read "public/#{css_dir}/#{file}.css"
    end

    on 'login' do
      res.write render('views/layout.haml') { render 'views/login.haml' }
    end

    on 'logout' do
      # TODO: read username from session cookie
      # TODO: delete session cookie
      # TODO: redirect to '/'
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

    on 'login' do
      on param('username'), param('password'), param('remember-me') do |username,password,remember_me|
        # look-up user based on params[]
        user = User.find(:name=>username).first
        if user
          # set session cookie
          session['user_id'] = user.id
          session[:requester] = env['REMOTE_ADDR']
          # TODO: set cookie expiration based on remember_me
          # TODO: authenticate based on params[]
          res.write [username,password,remember_me, session.inspect].join(' | ')
          # TODO: redirect to /
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