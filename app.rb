require "cuba"
require "cuba/render"
require 'haml'

require File.expand_path 'models', File.dirname(__FILE__)


Cuba.plugin Cuba::Render

Cuba.define do
  on get do

    on root do
      # TODO: if user is logged in, display user's timeline, else display global timeline
      res.write render( 'views/timeline.haml', :posts=>Post.all )
    end

    # /:username
    # this should be last
    # if user is not found, return 404
    on "(\\w+)" do |username|
      user = User.find_by_username(username)
      if user
        res.write render( 'views/user.haml', {:username=>username, :user=>user})
      else
        res.status = 404
        # TODO: move to dedicated 404 page
        res.write "<h1>404: Not Found</h1>"
      end
    end

  end
end