require "cuba"
require "cuba/render"
require 'haml'
require 'ohm'

Ohm.connect

Dir[ File.join File.expand_path( File.dirname __FILE__ ), 'models', '*.rb' ].each do |model_file|
  require model_file
end

Cuba.plugin Cuba::Render

Cuba.define do
  on get do

    on root do
      # TODO: if user is logged in, display user's timeline, else display global timeline
      res.write render('views/layout.haml') { render( 'views/timeline.haml', :posts=>Post.all.sort_by(:created_at, :order=>"DESC") ) }
    end

    css_dir = 'css'
    on css_dir, extension('css') do |file|
      res.headers["Content-Type"] = "text/css; charset=utf-8"
      res.write File.read "public/#{css_dir}/#{file}.css"
    end

    on 'login' do
      # TODO: render('views/layout.haml') {'views/layout'}
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
    on '/login' do
      # TODO: look-up user and authenticate based on params[]
      # TODO: set session cookie
      # TODO: redirect to /#{username}
    end
  end

end