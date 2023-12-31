class PostsController < ApplicationController
  include Stomp::Controller

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = build_record_for(Post)
  end

  def create
    @post = Post.new(post_params)

    if params[:commit] == "create" && @post.all_steps_valid?
      @post.save
      redirect_to post_path @post
    else
      @post.step!(params[:commit])
      redirect_to next_step_path_for(@post, path: :new_post_path)
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :url, :author, :description, :content, :serialized_steps_data)
  end
end
