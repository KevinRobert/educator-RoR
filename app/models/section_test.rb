class SectionTest < ActiveRecord::Base
  
  belongs_to :section
  belongs_to :test

  def completed_rate
    rate = 0

    total_students = self.section.users.length
    students_taken = UserTest.joins(:user)
                              .where(users: {section_id: self.section_id}, test_id: self.test_id, status: UserTest::FINISHED)
                              .select("user_id").group("user_id")

    if students_taken.length == 0
      rate = 0
    else
      rate = total_students * 100 / students_taken.length
    end

    rate.to_i
  end
end