class PostsController < ApplicationController
  def new
    @post = Post.new(title: "Mon titre", description: "Ma description", content: "Mon contenu")
  end

  def create
    @post = Post.new(post_params)
    debugger
  end

  private

  def post_params
    params.require(:post).permit(:title, :description, :content, :steps_data)
  end
end
