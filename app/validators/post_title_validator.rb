class PostTitleValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:title, "can't be blank") if record.title.blank?
  end
end