class PostsController < ApplicationController
  def new
    @post = Post.new(current_step: :step_1)
  end

  def create
    @post = Post.new(post_params)

    if @post.valid?
      @post.next_step!
      render :new, status: :ok
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :description, :content, :serialized_steps_data)
  end
end
