module Stomp
  module Model
    extend ActiveSupport::Concern

    STOMP_ATTRIBUTES = [:current_step, :previous_step, :completed_steps, :completed, :steps_data, :create_attempt, :serialized_steps_data]
    attr_accessor *STOMP_ATTRIBUTES

    included do
      class_attribute :steps, :steps_attributes, :steps_data, :stomp_validation

      after_initialize :set_default_values
    end

    class_methods do
      def define_steps(steps)
        self.steps_attributes = steps.values.flatten + STOMP_ATTRIBUTES
        self.steps = steps.keys

        define_method :serialized_steps_data do
          attributes
            .select { |k, _| steps_attributes.include?(k.to_sym) }
            .merge(current_step: current_step, previous_step: previous_step, create_attempt: create_attempt, completed_steps: completed_steps)
            .to_json
        end

        steps.each do |step, attributes|
          define_method "#{step}_attributes" do
            attributes
          end

          define_method "#{step}?" do
            current_step == step
          end
        end
      end

      def define_step_validations(step_validations)
        step_validations.each do |step, validations|
          if validations.is_a? Hash
            validations.each do |attribute, validation|
              validates attribute, **validation, if: ->(record) { record.current_step == step }
            end
          else
            validates_with validations, if: ->(record) { record.current_step == step }
          end
        end
      end

      def stomp!(options)
        self.stomp_validation = options[:validate]
      end
    end

    def initialize(*args)
      deserialize_and_set_data(args.first&.fetch(:serialized_steps_data, nil))
      super
      update_attributes_from_step_data
    end

    def step!(step)
      set_create_attempt!(step)
      return next_step! if step.to_sym == :next
      return previous_step! if step.to_sym == :previous
      return false unless steps.include?(step.to_sym)

      update_completed_steps

      if self.stomp_validation == :each_step
        return all_steps_valid?(after: step) unless completed_steps.include?(step.to_sym)
      end

      self.current_step = step
    end

    def next_step!
      update_completed_steps
    
      if self.stomp_validation == :each_step
        self.previous_step = current_step
        return false unless valid?
      end
    
      if current_step == steps.last
        self.completed = true
        return false
      end
    
      index = steps.index(current_step)
      self.current_step = steps[index + 1]
    end

    def previous_step! 
      index = steps.index(current_step)

      if index > 0
        self.completed_steps.delete(steps[index - 1])
        self.current_step = steps[index - 1]
      end
    end

    def has_previous_step?
      steps.index(current_step) > 0
    end

    def has_next_step?
      steps.index(current_step) < steps.length - 1
    end

    def current_step_is?(step)
      current_step == step
    end

    def current_step=(step)
      @previous_step = @current_step.presence
      @current_step = step&.to_sym
    end

    def previous_step=(step)
      @previous_step = step&.to_sym
    end

    def completed?
      completed
    end

    def create_attempt?
      create_attempt
    end

    def first_step?
      current_step == steps.first
    end

    def last_step?
      current_step == steps.last
    end

    def all_steps_valid?(options = {})
      stored_step = options[:after] || current_step

      steps.each do |step|
        self.current_step = step
        return false unless valid?
      end

      self.current_step = stored_step
      true
    end

    def should_validate?
      return true if create_attempt
      return true if current_step == previous_step

      public_send("#{current_step}_attributes").any? { |attribute| public_send(attribute).present? }
    end

    private

    def set_create_attempt!(step)
      step.to_sym == :create ? self.create_attempt = true : self.create_attempt = false
    end

    def update_completed_steps
      return unless self.stomp_validation == :each_step

      valid? ? self.completed_steps |= [current_step] : self.completed_steps.delete(current_step)
    end
    

    def deserialize_and_set_data(serialized_data)
      return unless serialized_data
    
      JSON.parse(serialized_data).tap do |data|
        self.steps_data = data
        self.previous_step = data["previous_step"]
        self.current_step = data["current_step"]
        self.create_attempt = data["create_attempt"]
        self.completed_steps = data["completed_steps"]&.map(&:to_sym) || []
      end
    end

    def update_attributes_from_step_data
      return if steps_data.nil?

      steps_data.each { |k, v| send("#{k}=", v) if send(k).nil? }
    end

    def set_default_values
      self.current_step ||= steps.first
      self.completed_steps ||= []
    end
  end
end