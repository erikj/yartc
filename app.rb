require "cuba"
require "cuba/render"
require 'haml'

require File.expand_path 'models', File.dirname(__FILE__)


Cuba.plugin Cuba::Render

Cuba.define do
  on get do
    on root do
      # get posts

    end
  end
end