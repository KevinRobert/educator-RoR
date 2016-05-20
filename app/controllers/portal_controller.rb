class PortalController < ApplicationController
  include ApplicationHelper, TestEvaluation

  before_action :authenticate_user!
  
  def index

    if current_user.student? && current_user.section_id.present?
      # check test availability
      @section_tests = SectionTest.where(:section_id => current_user.section_id)
                                  .order(start_at: :asc)

      @test_time_available = 2 # not available
      @time_diff = []
      @user_test_id = nil
      @section_test = []

      @section_tests.each do |st|
        current_time = Time.now.in_time_zone("New Delhi")

        @test_time_available, @time_diff, @user_test_id = evaluate_availability(st, current_user)
        # If current user has available test get it
        if @test_time_available == 0 || @test_time_available == 3
          @section_test << st
        end
      end
    end

    @subjects = Test.pluck(:subject).compact.uniq
    @chapters = Test.pluck(:topic).compact.uniq

    @test_progress = []
    Test.select("syllabus").group("syllabus").each do |syllabus|

      Test.where(:syllabus => syllabus[:syllabus]).select("subject").group("subject").each do |subject|

        tests = Test.where(:syllabus => syllabus[:syllabus], :subject => subject[:subject])
        i = 0

        tests.each do |test|
          i = i + 1 if UserTest.where(:test_id => test.id, :status => "Finished").present?
        end

        @test_progress << {
          syllabus: syllabus[:syllabus],
          subject: subject[:subject],
          percent: i * 100 / tests.length
        }
      end
    end

    @recent_tests = current_user.recent_activities
    @test_results = UserTest.search(params, current_user.id).order(id: :asc).paginate(:page => params[:page])
  end

  def result

    @user_test = UserTest.find(params[:id])
    authorize! :progress_result, @user_test
    
    # Calculate user's rate
    if @user_test.user.section.present?
      @school_grade_users = User.where(school_id: @user_test.user.section.school_id, grade: @user_test.user.section.grade)
      @school_grade_section_users = User.where(school_id: @user_test.user.section.school_id, grade: @user_test.user.section.grade, section: @user_test.user.section_id)

      # user rate by students of school grade
      @grade_users_test_taken = 1
      @grade_user_rate = 1
      @school_grade_users.each do |user|
        school_user_test = UserTest.where(
                                    :user_id => user.id, 
                                    :test_id => @user_test.test_id,
                                    :status => "Finished"
                                  ).order(score: :desc).first

        @grade_users_test_taken += 1 if school_user_test.present?

        @grade_user_rate += 1 if school_user_test.present? && school_user_test.score.to_f > @user_test.score
      end

      
      if @school_grade_users.length == 0
        @grade_user_rate_percent = 1  # top 1% manually
      else
        @grade_user_rate_percent = 100 - ((@grade_users_test_taken.to_f - @grade_user_rate) / @grade_users_test_taken) * 100
        @grade_user_rate_percent = @grade_user_rate_percent.ceil
      end      

      # user rate by students of school grade section
      @section_user_rate = 1
      @school_grade_section_users.each do |user|
        school_user_test = UserTest.where(
                                    :user_id => user.id, 
                                    :test_id => @user_test.test_id,
                                    :status => "Finished"
                                  ).order(score: :desc).first
        @section_user_rate += 1 if school_user_test.present? && school_user_test.score.to_f > @user_test.score
      end
      
      if @school_grade_section_users.length == 0
        @section_user_rate_percent = 1  # top 1% manually
      else
        @section_user_rate_percent = 100 - ((@school_grade_section_users.length.to_f - @section_user_rate) / @school_grade_section_users.length) * 100
        @section_user_rate_percent = @section_user_rate_percent.ceil
      end


      # user rate by students across all schools' grade
      @school_user_rate = 1
      @users_test_taken = 1
      @all_school_users = User.where(grade: @user_test.user.section.grade)
      @all_school_users.each do |user|
        school_user_test = UserTest.where(
                                    :user_id => user.id, 
                                    :test_id => @user_test.test_id,
                                    :status => "Finished"
                                  ).order(score: :desc).first
        
        @users_test_taken += 1 if school_user_test.present?

        if school_user_test.present? && school_user_test.score.to_f > @user_test.score
          @school_user_rate += 1
        end
      end

      @school_user_rate_percent = 100 - ((@users_test_taken.to_f - @school_user_rate) / @users_test_taken) * 100
      @school_user_rate_percent = @school_user_rate_percent.ceil
    end

    # Accumulate data for drawing charts
    if @user_test.test.report_by == "Subject"
      # by subject
      @available_charts = []
      test_subjects = @user_test.test.get_available_subjects
      test_subjects.each do |test_subject|
        subject_questions = Question.joins(:test_questions)
                                    .where(test_questions: {test_id: @user_test.test_id}, subject: test_subject)

        correct, wrong = 0, 0
        subject_questions.each do |tq|
          is_correct_answer?(@user_test.id, tq.id) ? correct += 1 : wrong += 1
        end

        @available_charts << {
          item: test_subject,
          correct: correct,
          wrong: wrong
        }
      end
    elsif @user_test.test.report_by == "Topic"
      # by topic
      @available_charts = []
      test_topics = @user_test.test.get_available_topics
      test_topics.each do |test_topic|
        topic_questions = Question.joins(:test_questions)
                                  .where(test_questions: {test_id: @user_test.test_id}, topic: test_topic)

        correct, wrong = 0, 0
        topic_questions.each do |tq|
          is_correct_answer?(@user_test.id, tq.id) ? correct += 1 : wrong += 1
        end

        @available_charts << {
          item: test_topic,
          correct: correct,
          wrong: wrong
        }
      end
    elsif @user_test.test.report_by == "Concept"

      # by concept
      @available_charts = []
      test_concepts = @user_test.test.get_available_concepts
      test_concepts.each do |test_concept|
        concept_questions = Question.joins(:test_questions).where(test_questions: {test_id: @user_test.test_id}).where("questions.concepts like ?","%#{test_concept}%")
        correct, wrong = 0, 0
        concept_questions.each do |tq|
          is_correct_answer?(@user_test.id, tq.id) ? correct += 1 : wrong += 1
        end

        @available_charts << {
          item: test_concept,
          correct: correct,
          wrong: wrong
        }
      end
    end

    # by type
    @available_types = []
    type_questions = @user_test.test.get_available_types
    #Question::TYPES.each do |q_type|
    type_questions.each do |q_type|
      type_questions = Question.joins(:test_questions)
                              .where(test_questions: {test_id: @user_test.test_id}, question_type: q_type)

      correct, wrong = 0, 0
      type_questions.each do |tq|
        is_correct_answer?(@user_test.id, tq.id) ? correct += 1 : wrong += 1
      end

      @available_types << {
        type: q_type,
        correct: correct,
        wrong: wrong
      }
    end

    # by difficulty
    @available_difficulties = []
    Question::DIFFICULTIES.each do |q_difficulty|
      difficulty_questions = Question.joins(:test_questions).where(test_questions: {test_id: @user_test.test_id}, difficulty: q_difficulty)

      correct, wrong = 0, 0
      difficulty_questions.each do |dq|
        is_correct_answer?(@user_test.id, dq.id) ? correct += 1 : wrong += 1
      end

      @available_difficulties << {
        difficulty: q_difficulty,
        correct: correct,
        wrong: wrong
      }
    end
  end
end