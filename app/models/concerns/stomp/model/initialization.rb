module Stomp
  module Model
    class DynamicStepError < StandardError; end
    
    module Initialization
      def initialize(*args)
        deserialize_and_set_data(args.first&.fetch(:serialized_steps_data, nil))
        super
        update_attributes_from_step_data
        update_dynamic_steps
      end

      private

      def update_dynamic_steps
        return if stomp_validation == :once

        dynamic_steps = self.class.steps.dup
        
        self.class.conditional_steps.each do |step, condition|
          if condition.call(self).nil?
            next_step = steps[steps.index(step) + 1]
          else
            next_step = condition.call(self)
            
            if step_index_for(next_step) < step_index_for(step)
              raise DynamicStepError, "Dynamic step #{next_step} cannot be before #{step}"
            end
          end
          
          index = dynamic_steps.index(step)
          dynamic_steps[index + 1] = next_step if index
          dynamic_steps.uniq!
        end

        self.steps = dynamic_steps | steps
      end

      def set_default_values
        self.current_step ||= steps.first
        self.completed_steps ||= []
      end
    end
  end
end
