class Post < ApplicationRecord
  include Stomp

  define_steps step_1: [:title], 
               step_2: [:description], 
               step_3: [:content] 

  define_step_validations step_1: PostTitleValidator
end

