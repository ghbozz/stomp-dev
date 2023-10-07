class Post < ApplicationRecord
  include Stomp::Model

  stomp! validate: :each_step
  
  define_steps step_1: [:title], 
               step_2: [:description], 
               step_3: [:content] 

  define_step_validations step_1: PostTitleValidator
  define_step_validations step_2: PostDescriptionValidator
end

