class PagesController < ApplicationController
  def homepage
    @posts = FrancisCms::Post.limit(5).order('published_at desc')
  end
end
