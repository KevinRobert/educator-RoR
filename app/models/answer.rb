class Answer < ActiveRecord::Base
  before_save :set_options_empty

  belongs_to :question

  def options=(answers_array)
    if answers_array.present?
      write_attribute(:options, answers_array.map(&:to_i))
    else
      write_attribute(:options, [])
    end
  end

  def options_array
    if self.present? && self.options.present?
      return JSON.parse(self.options)
    else
      return []
    end
  end

  private

  def set_options_empty
    self[:options] = [] unless self.options.present?
  end

end