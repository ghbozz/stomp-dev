module Stomp
  module Model
    extend ActiveSupport::Concern

    STOMP_ATTRIBUTES = [:current_step, :completed_steps, :completed, :steps_data, :serialized_steps_data]
    attr_accessor *STOMP_ATTRIBUTES

    included do
      class_attribute :steps, :steps_attributes, :steps_data, :stomp_validation
    end

    class_methods do
      def define_steps(steps)
        self.steps_attributes = steps.values.flatten + STOMP_ATTRIBUTES
        self.steps = steps.keys

        define_method :serialized_steps_data do
          attributes
            .select { |k, _| steps_attributes.include?(k.to_sym) }
            .merge(current_step: current_step, completed_steps: completed_steps)
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
      if args.first&.fetch(:serialized_steps_data, nil)
        JSON.parse(args.first[:serialized_steps_data]).tap do |data|
          self.steps_data = data
          self.current_step = data["current_step"]
          self.completed_steps = data["completed_steps"]&.map(&:to_sym) || []
        end
      end
      
      self.current_step ||= steps.first
      self.completed_steps ||= []

      super
      update_attributes_from_step_data
    end

    def step!(step)
      return next_step! if step.to_sym == :next
      return previous_step! if step.to_sym == :previous
      return false unless steps.include?(step.to_sym)

      if valid?
        self.completed_steps << current_step unless completed_steps.include?(current_step)
      else
        self.completed_steps.delete(current_step)
      end

      if self.stomp_validation == :each_step
        return all_steps_valid?(after: step) unless completed_steps.include?(step.to_sym)
      end

      self.current_step = step
    end

    def next_step!
      if self.stomp_validation == :each_step
        return false unless valid?
      end

      if current_step == steps.last
        self.completed = true
        return false
      end

      self.completed_steps << current_step if !completed_steps.include?(current_step)
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
      @current_step = step&.to_sym
    end

    def completed?
      completed
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

    private

    def update_attributes_from_step_data
      return if steps_data.nil?

      steps_data.each { |k, v| send("#{k}=", v) if send(k).nil? }
    end
  end
end