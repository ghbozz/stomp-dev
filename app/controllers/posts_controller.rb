class PostsController < ApplicationController
  def new
    @post = Post.new(serialized_steps_data: params[:serialized_steps_data])
  end

  def create
    @post = Post.new(post_params)

    if @post.valid?
      @post.step!(params[:commit])
      redirect_to new_post_path(serialized_steps_data: @post.serialized_steps_data)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :description, :content, :serialized_steps_data)
  end
end
