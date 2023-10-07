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

    if @post.valid?
      @post.step!(params[:commit])

      if @post.completed? && @post.all_steps_valid?
        @post.save
        redirect_to post_path @post
        return
      end

      redirect_to new_post_path(serialized_steps_data: @post.serialized_steps_data)
    else
      if params[:commit] == "previous"
        @post.previous_step!
      end

      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :description, :content, :serialized_steps_data)
  end
end
