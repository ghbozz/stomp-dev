module Stomp
  module Controller
    def build_record_for(klass)
      klass.new(serialized_steps_data: params[:serialized_steps_data])
    end

    def next_step_path_for(record, options = {})
      send("#{options[:path]}", serialized_steps_data: record.serialized_steps_data)
    end
  end
end