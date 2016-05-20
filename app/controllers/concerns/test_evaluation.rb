# Evaluate if a test is available at this moment

module TestEvaluation
  extend ActiveSupport::Concern

  def evaluate_availability(section_test, user)
    test_time_available = 2 # expired
    time_diff = [0, 0] # time diff in days on hours
    user_test_id = nil

    if section_test.present?
      # check if the user has taken this test
      user_test = UserTest.where(:user_id => user.id, :test_id => section_test.test_id).order(created_at: :desc).first
      if user_test.present? 
        if user_test.status == "Finished"
          if section_test.test.allow_retry
            test_time_available = 0 # available retry
          else
            test_time_available = 2 # not allowed to retry
          end
        else
          test_time_available = 3 # continue test
          user_test_id = user_test.id
        end
      else
        current_time = Time.now.in_time_zone("New Delhi")

        if section_test.start_at.present? &&
              current_time > section_test.start_at &&
              current_time < section_test.end_at
          test_time_available = 0 #ready to take test
        elsif section_test.start_at.present? && current_time < section_test.start_at
          test_time_available = 1 #future
          hours_diff = ((section_test.start_at - current_time) / 1.hour).round
          time_diff = hours_diff.divmod(24)
        elsif section_test.end_at.present? && current_time > section_test.end_at
          test_time_available = 2 #expired
        else
          test_time_available = 0 # available anytime
        end
      end
    end

    [test_time_available, time_diff, user_test_id]
  end
end
