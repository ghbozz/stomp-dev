module Stomp
  extend ActiveSupport::Concern

  STOMP_ATTRIBUTES = [:current_step, :completed_steps, :steps_data]
  attr_accessor *STOMP_ATTRIBUTES

  included do
    class_attribute :steps, :steps_attributes, :steps_data
  end

  class_methods do
    def define_steps(steps)
      self.steps_attributes = steps.values.flatten + STOMP_ATTRIBUTES
      self.steps = steps.keys

      define_method :steps_data do
        attributes.select { |k, _| steps_attributes.include?(k.to_sym) }
      end
    end

    def define_step_validations(step_validations)
      step_validations.each do |step, validations|
        validates_with validations, if: ->(record) { record.current_step == step }
      end
    end
  end

  def initialize(*args)
    super
    update_attributes_from_step_data
  end

  def save
    return false unless valid?

    super
  end

  def update_attributes_from_step_data
    steps_data.each do |k, v|
      send("#{k}=", v)
    end
  end

  # def all_steps_completed?
  #   steps.all? { |step| completed_steps.include?(step) }
  # end
end