class TestsController < ApplicationController
  include TestEvaluation

  before_action :authenticate_user!

  def main
  end

  def index
    @tests = []
    all_tests = Test.where(subject: params[:subject])

    all_tests.each do |test|
      # if user took this test already, skip it
      old_test = UserTest.where(:user_id => current_user.id, :test_id => test.id, :status => "Finished")
      next if !test.allow_retry && old_test.present?

      section_tests = SectionTest.where(:section_id => current_user.section_id, :test_id => test.id)
      next unless section_tests.present?

      @tests << test
    end
  end

  def start
    # Show test general description before starting
    @test = Test.find(params[:test_id])
    @test_time_available = 0
    @user_test_id = nil

    unless current_user.website_admin?
      if current_user.section.present?
        @section_test = SectionTest.where(:section_id => current_user.section.id, :test_id => @test.id).try(:first)
        @test_time_available, @time_diff, @user_test_id = evaluate_availability(@section_test, current_user)
      else
        @test_time_available = 2
      end
    else
      @test_time_available = 0
    end
  end

  # Start the test by first question
  def test
    @test = Test.find(params[:test_id])
    @user = current_user
    @test_response = @test.test_responses.build

    # test_responses = TestResponse.where(user_id: current_user.id, test_id: @test.id)
    # @elapsed_time = test_responses.sum(:answer_time)
    @elapsed_time = 0
    @all_answered = false
    @is_last_question = false

    # generate randomized question order
    test_questions = Question.joins(:tests).where(:tests => { :id => @test.id})
    subjects = test_questions.select("subject").group("subject")
    question_ids = []
    subjects.each do |subject|
      question_ids << test_questions.where(:subject => subject[:subject]).pluck(:id).try(:shuffle)
    end
    question_ids.flatten!

    @user_test = UserTest.create(
      user_id: current_user.id, 
      test_id: @test.id, 
      status: UserTest::STARTED,
      random_order: question_ids.join(",")
    )

    @question = Question.find_by_id(question_ids.first)
    @question_count = test_questions.length
    @question_idx = 1
  end

  # continue test
  def continue
    @test = Test.find(params[:test_id])
    @user_test = UserTest.where(user_id: current_user.id, test_id: @test.id).in_progress.order(created_at: :desc).first

    test_responses = @user_test.test_responses

    questions_all = @user_test.random_order.present? ? @user_test.random_order.split(",").map(&:to_i) : []
    # get question ids taken
    questions_taken = test_responses.pluck(:question_id)
    # select random question
    available_questions = questions_all - questions_taken
  
    is_finished = !available_questions.present?
    unless is_finished
      @question = Question.find(available_questions[0])
      @question_idx = questions_taken.length + 1
    else
      @question = Question.find(questions_all.first)
      @question_idx = 1
    end

    @question_count = questions_all.length
    @elapsed_time = test_responses.sum(:answer_time)
    @all_answered = true
    
    (0..questions_all.length - 2).each do |q_id|
      q = Question.find(questions_all[q_id])
      if q.answer_type != "Text"
        tr = TestResponse.where(
                            user_test_id: @user_test.id, 
                            question_id: q.id
                          ).try(:first)
        if tr.blank? || tr.answer_options.blank?
          @all_answered = false
          break
        end
      end
    end

    @is_last_question = false
    # set the test response for the current @question
    @test_response = TestResponse.where(
                                    user_test_id: @user_test.id, 
                                    question_id: @question.id
                                  ).first
    @test_response = @test.test_responses.build unless @test_response.present?

    render 'tests/test'
  end

  # Save test answers and response time
  def submit
    @question = nil
    is_finished = false

    @test = Test.find(params[:test_id])
    @user_test = UserTest.find(test_response_params[:user_test_id])
    test_questions = @user_test.random_order.split(",").map(&:to_i)

    # Avoid F5/Refresh button request
    test_response_params[:answer_options] = [] unless test_response_params[:answer_options].present?
    @test_response = TestResponse.where(
                                  user_test_id: @user_test.id,
                                  question_id: test_response_params[:question_id]
                                ).first

    # Update existing test response
    unless @test_response.present?
      @test_response = TestResponse.create test_response_params
    else
      #don't update response during prev/next navigation
      if params["nav-type"] != "prev" && params["nav-type"] != "next"
        @test_response.update_attributes(
          answer_time: test_response_params[:answer_time].to_i + @test_response.answer_time.to_i,
          answer_options: test_response_params[:answer_options].present? ? test_response_params[:answer_options] : []
        )
      end
    end

    test_responses = @user_test.test_responses

    if @test.timeout.present?
      if params["nav-type"] == "prev"
        test_questions.each_with_index do |q, q_index|
          if q == test_response_params[:question_id].to_i
            if q_index == 0
              # this is last question so it goes to finish page
              @question = Question.find(test_questions[0])
              @question_idx = 1
            else
              @question = Question.find(test_questions[q_index - 1])
              @question_idx = q_index
            end

            break
          end
        end
      else
        test_questions.each_with_index do |q, q_index|
          if q == test_response_params[:question_id].to_i
            if q_index == test_questions.length - 1
              # this is last question so it goes to finish page
              redirect_to test_finish_path and return
            else
              @question = Question.find(test_questions[q_index + 1])
            end

            @question_idx = q_index + 2
            break
          end
        end
      end

      # check if all answers were selected except current question
      @is_last_question = (@question_idx == @test.questions.length)
      @all_answered = true
      (0..test_questions.length - 2).each do |q_id|
        q = Question.find(test_questions[q_id])
        if q.answer_type != "Text"
          tr = TestResponse.where(
                              user_test_id: @user_test.id, 
                              question_id: q.id
                            ).try(:first)
          if tr.blank? || tr.answer_options.blank?
            @all_answered = false
            break
          end
        end
      end

      @elapsed_time = test_responses.sum(:answer_time)
      is_finished = @test.timeout.present? && (@elapsed_time >= @test.timeout)
    else
      questions_all = test_questions

      # get question ids taken
      questions_taken = test_responses.pluck(:question_id)

      # select random question
      available_questions = questions_all - questions_taken
    
      is_finished = !available_questions.present?
      if !is_finished
        @question = Question.find(available_questions[0])
        @question_idx = questions_taken.length + 1
      end
    end

    is_finished = true if params["test_response"]["force_end"] == "true"

    if is_finished
      redirect_to test_finish_path
    else
      # set the test response for the current @question
      @test_response = TestResponse.where(
                                      user_test_id: @user_test.id, 
                                      question_id: @question.id
                                    ).first
      @test_response = @test.test_responses.build unless @test_response.present?

      # Update user_test status
      @user_test.update_attributes(:status => UserTest::IN_PROGRESS) if @user_test.status != UserTest::FINISHED

      @question_count = @test.questions.length

      render 'tests/test'
    end
  end

  # Save final test result
  def finish
    @correct_answers_count, @skipped_answers_count,  @wrong_answers_count = 0, 0, 0

    @test = Test.find(params[:test_id])
    @user_test = UserTest.where(user_id: current_user.id, test_id: @test.id).order(created_at: :desc).first

    # calculate test score and elapsed time
    test_responses = TestResponse.where(user_test_id: @user_test.id)
    @elapsed_time = test_responses.sum(:answer_time)

    test_responses.each do |test_response|
      correct_answers = JSON.parse(test_response.question.answer.options)
      answer_array = test_response.answer_options.present? ? test_response.answer_options : '[]'
      user_answers = JSON.parse(answer_array)
  
      if correct_answers.uniq.sort == user_answers.uniq.sort
        @correct_answers_count += 1
      elsif user_answers.length != 0 && correct_answers.uniq.sort != user_answers.uniq.sort
        @wrong_answers_count += 1
      end
    end
    @skipped_answers_count = @test.questions.length - @correct_answers_count - @wrong_answers_count

    #@wrong_answers_count = @test.questions.length - @correct_answers_count
    score = @correct_answers_count * 100 / @test.questions.length

    @user_test.update_attributes(
      status: UserTest::FINISHED,
      total_questions: @test.questions.length,
      correct_answers: @correct_answers_count,
      score: score,
      time: @elapsed_time
    )
  end

  def contact
    # @message = Message.new(message_params)
    
    if params[:name].present? || params[:email].present? || params[:message].present?
      MessageMailer.report_message(params[:name], params[:email], params[:message]).deliver
      
      render json: {}, status: :created and return
    else
      render json: { :errors => "Please input necessary fields below." }, status: 422 and return
    end

    render json: { :errors => "Please input mandatory fields." }, status: 422 and return
  end

  private

  def test_response_params
    params.require(:test_response).permit(:test_id, :question_id, :user_id, :user_test_id, :answer_time, answer_options: [])
  end

  def message_params
    params.permit(:name, :email, :message)
  end

end 