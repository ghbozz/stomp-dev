module Stomp
  module Controller
    def build_record_for(klass)
      klass.new(serialized_steps_data: params[:serialized_steps_data])
    end
  end
end