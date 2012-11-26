require "cuba"
require "cuba/render"
require 'haml'

require File.expand_path 'models', File.dirname(__FILE__)


Cuba.plugin Cuba::Render

Cuba.define do
  on get do

    on root do
      res.write render( 'views/timeline.haml', :posts=>Post.all )
    end

  end
end