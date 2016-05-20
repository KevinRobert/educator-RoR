module ApplicationHelper

  # Convert number to alphabet, ie, 64=A
  def to_alphabet(number)
    (number + 64).chr
  end

  # Concatenate school's address
  def school_address(school)
    address = ""
    if school.present?
      address = school.address1
      address = "#{address} #{school.address2}" if school.address2.present?
      address = "#{address}, #{school.city}" if school.city.present?
      address = "#{address}, #{school.state}" if school.state.present?
    end

    address
  end

  # Render sortable column link
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "sortable #{sort_direction}" : "sortable"
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to '', {:sort => column, :direction => direction}, {:class => css_class}
  end

  # Check if user answer is same to question answer
  def is_correct_answer?(user_test_id, question_id)
    user_answer = TestResponse.where(
                                user_test_id: user_test_id,
                                question_id: question_id
                              ).first
    user_answer = JSON.parse(user_answer.answer_options) rescue []

    q_answer = Answer.where(question_id: question_id).first
    q_answer = JSON.parse(q_answer.options) rescue []
    
    q_answer.uniq.sort == user_answer.uniq.sort ? true : false
  end

  def upcoming_test_title(section_test)
    "#{section_test.start_at.strftime('%B %eth, %Y')} - #{section_test.test.name} Test [Subject: #{section_test.test.subject}, Chapter: #{section_test.test.topic}] for #{section_test.section.name}"
  end

  # text title for recent tests list on dashboard page
  def recent_test_title(section_test)
    "#{section_test.section.name} - View results for #{section_test.test.name} Test [Subject: #{section_test.test.subject}, Chapter: #{section_test.test.topic}] 
    on #{section_test.start_at.strftime('%B')} #{section_test.start_at.day.ordinalize}, #{section_test.start_at.strftime('%Y')}"
  end

  def percentile(total, value)
    total == 0 ? "0%" : "#{'%.2f' % (value.to_f * 100 / total)}%"
  end
end
