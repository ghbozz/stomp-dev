class PostDescriptionValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:description, "can't be blank") if record.description.blank?
  end
end