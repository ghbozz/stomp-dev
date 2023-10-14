class Post < ApplicationRecord
  include Stomp::Model

  stomp! validate: :each_step
  
  define_steps step_1: [:title, :author], 
               step_2: [:description], 
               step_3: [:content],
               step_4: [:url]

  define_step_validations step_1: { 
                            title: { presence: true, length: { minimum: 5 } }, 
                            author: { presence: true }
                          },
                          step_3: {
                            content: { presence: true }
                          }

  
  define_step_validations step_2: PostDescriptionValidator

  define_conditional_steps step_1: ->(record) { :step_3 if record.title == 'step_3' },
                           step_3: ->(record) { record.content == 'step_2' ? :step_2 : :step_4 }
end

