class Post < ApplicationRecord
  include Stomp::Model

  stomp! validate: :each_step
  
  define_steps step_1: [:title, :url, :author], 
               step_2: [:description], 
               step_3: [:content] 

  define_step_validations step_1: { 
    title: { presence: true, length: { minimum: 5 } }, 
    url: { presence: true } 
  }
  
  define_step_validations step_2: PostDescriptionValidator
end

